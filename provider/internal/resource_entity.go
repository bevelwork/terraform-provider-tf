package internal

import (
	"context"

	"github.com/hashicorp/terraform-plugin-sdk/v2/diag"
	"github.com/hashicorp/terraform-plugin-sdk/v2/helper/schema"

	"terraform-provider-factorio/client"
)

func resourceEntity() *schema.Resource {
	return &schema.Resource{
		CreateContext: resourceEntityCreate,
		ReadContext:   resourceEntityRead,
		UpdateContext: resourceEntityUpdate,
		DeleteContext: resourceEntityDelete,
		Description:   "A LuaEntity in Factorio (https://lua-api.factorio.com/latest/LuaEntity.html), see LuaSurface.create_entity for creation reference (https://lua-api.factorio.com/latest/LuaSurface.html#LuaSurface.create_entity) ",

		Schema: map[string]*schema.Schema{
			"unit_number": {
				Type:        schema.TypeInt,
				Computed:    true,
				Description: "unit_number is Factorio's concept of an ID",
			},
			"surface": {
				Type:        schema.TypeString,
				Optional:    true,
				Default:     "nauvis",
				Description: "The LuaSurface on which the LuaEntity is placed (https://lua-api.factorio.com/latest/LuaSurface.html)",
				ForceNew:    true,
			},
			"name": {
				Type:        schema.TypeString,
				Required:    true,
				Description: "The prototype name of the LuaEntity (https://wiki.factorio.com/Prototype_definitions)",
				ForceNew:    true,
			},
			"position": integerPositionSchema(&schema.Schema{
				Required:    true,
				Description: "The position of the LuaEntity.",
				ForceNew:    true,
			}),
			// TODO force 'north' for entities with the 'not-rotatable' flag
			"direction": directionSchema(&schema.Schema{
				Type:        schema.TypeString,
				Optional:    true,
				Default:     "north",
				Description: "Which direction the LuaEntity faces.",
			}),
			"force": {
				Type:        schema.TypeString,
				Optional:    true,
				Default:     "player",
				Description: "The force of this LuaEntity, eg. \"player\", \"enemy\", \"neutral\" (https://lua-api.factorio.com/latest/LuaControl.html#LuaControl.force)",
			},
			"entity_specific_parameters": {
				Type:        schema.TypeMap,
				Optional:    true,
				Elem:        &schema.Schema{Type: schema.TypeString},
				Description: "A map of additional entity-specific parameters to be passed to create_entity (https://lua-api.factorio.com/latest/LuaSurface.html#LuaSurface.create_entity)",
				ForceNew:    true,
			},
			"contents": {
				Type:        schema.TypeList,
				Optional:    true,
				Description: "Items to place inside the entity (e.g., fuel in a burner mining drill)",
				Elem: &schema.Resource{
					Schema: map[string]*schema.Schema{
						"kind": {
							Type:        schema.TypeString,
							Required:    true,
							Description: "The item name (e.g., 'wood', 'coal')",
						},
						"qty": {
							Type:        schema.TypeInt,
							Required:    true,
							Description: "The quantity of the item",
						},
					},
				},
			},
		},
	}
}

func resourceEntityCreate(ctx context.Context, d *schema.ResourceData, m interface{}) diag.Diagnostics {
	c := m.(*client.FactorioClient)
	var opts client.EntityCreateOptions

	direction, err := client.ParseDirection(d.Get("direction").(string))
	if err != nil {
		return diag.FromErr(err)
	}

	surface := d.Get("surface").(string)
	name := d.Get("name").(string)
	position := client.Position{
		X: float32(d.Get("position.0.x").(float64)),
		Y: float32(d.Get("position.0.y").(float64)),
	}
	force := d.Get("force").(string)
	
	// Extract contents
	var contents []client.Content
	if contentsList, ok := d.Get("contents").([]interface{}); ok && len(contentsList) > 0 {
		contents = make([]client.Content, 0, len(contentsList))
		for _, contentItem := range contentsList {
			contentMap := contentItem.(map[string]interface{})
			contents = append(contents, client.Content{
				Kind: contentMap["kind"].(string),
				Qty:  contentMap["qty"].(int),
			})
		}
	}

	// Check if a resource with matching attributes already exists
	// Match on surface, name, and position (key identifying attributes)
	tolerance := float32(0.1) // 0.1 tile tolerance
	query := &client.EntityQuery{
		Surface:          &surface,
		Name:             &name,
		Position:         &position,
		PositionTolerance: &tolerance,
	}
	
	existing, err := c.EntityList(query)
	if err != nil {
		return diag.FromErr(err)
	}
	
	var e *client.Entity
	if len(existing) > 0 {
		// Use the first matching entity
		e = &existing[0]
		// Update it if direction or force changed
		var updateOpts client.EntityUpdateOptions
		needsUpdate := false
		
		currentDirection := e.Direction.String()
		desiredDirection := direction.String()
		if currentDirection != desiredDirection {
			updateOpts.Direction = &direction
			needsUpdate = true
		}
		
		if e.Force != force {
			updateOpts.Force = &force
			needsUpdate = true
		}
		
		// Check if contents changed
		if d.HasChange("contents") {
			updateOpts.Contents = &contents
			needsUpdate = true
		}
		
		if needsUpdate {
			updated, err := c.EntityUpdate(e.UnitNumber, &updateOpts)
			if err != nil {
				return diag.FromErr(err)
			}
			e = updated
		}
	} else {
		// Create new entity
		opts.Surface = surface
		opts.Name = name
		opts.Position = position
		opts.Direction = direction
		opts.Force = force
		opts.EntitySpecificParameters = d.Get("entity_specific_parameters").(map[string]interface{})
		opts.Contents = contents

		created, err := c.EntityCreate(&opts)
		if err != nil {
			return diag.FromErr(err)
		}
		e = created
	}
	
	d.SetId(e.UnitNumber.String())
	return resourceEntityRead(ctx, d, m)
}

func writeAttributeToResource(diagOut *diag.Diagnostics, d *schema.ResourceData, key string, attr interface{}) {
	err := d.Set(key, attr)
	if err != nil {
		*diagOut = append(*diagOut, diag.FromErr(err)...)
	}
}

func flattenPosition(pos client.Position) []map[string]float64 {
	flat := make(map[string]float64)
	flat["x"] = float64(pos.X)
	flat["y"] = float64(pos.Y)
	return []map[string]float64{flat}
}

func flattenContents(contents []client.Content) []map[string]interface{} {
	if contents == nil {
		return []map[string]interface{}{}
	}
	result := make([]map[string]interface{}, len(contents))
	for i, content := range contents {
		result[i] = map[string]interface{}{
			"kind": content.Kind,
			"qty":  content.Qty,
		}
	}
	return result
}

func writeEntityToResourceData(e *client.Entity, d *schema.ResourceData) diag.Diagnostics {
	var diags diag.Diagnostics
	writeAttributeToResource(&diags, d, "unit_number", e.UnitNumber)
	writeAttributeToResource(&diags, d, "surface", e.Surface)
	writeAttributeToResource(&diags, d, "name", e.Name)
	writeAttributeToResource(&diags, d, "position", flattenPosition(e.Position))
	writeAttributeToResource(&diags, d, "direction", e.Direction.String())
	writeAttributeToResource(&diags, d, "force", e.Force)
	writeAttributeToResource(&diags, d, "contents", flattenContents(e.Contents))
	return diags
}

func resourceEntityRead(ctx context.Context, d *schema.ResourceData, m interface{}) diag.Diagnostics {
	c := m.(*client.FactorioClient)
	unitNumber, err := client.ParseUnitNumber(d.Id())
	if err != nil {
		return diag.FromErr(err)
	}
	entity, err := c.EntityGet(unitNumber)
	if err != nil {
		return diag.FromErr(err)
	}
	if entity == nil {
		d.SetId("")
		return nil
	}
	d.SetId(entity.UnitNumber.String())
	diags := writeEntityToResourceData(entity, d)
	return diags
}

func resourceEntityUpdate(ctx context.Context, d *schema.ResourceData, m interface{}) diag.Diagnostics {
	c := m.(*client.FactorioClient)
	unitNumber, err := client.ParseUnitNumber(d.Id())
	if err != nil {
		return diag.FromErr(err)
	}
	var opts client.EntityUpdateOptions
	if d.HasChange("direction") {
		direction, err := client.ParseDirection(d.Get("direction").(string))
		if err != nil {
			return diag.FromErr(err)
		}
		opts.Direction = &direction
	}
	if d.HasChange("force") {
		force := d.Get("force").(string)
		opts.Force = &force
	}
	if d.HasChange("contents") {
		var contents []client.Content
		if contentsList, ok := d.Get("contents").([]interface{}); ok && len(contentsList) > 0 {
			contents = make([]client.Content, 0, len(contentsList))
			for _, contentItem := range contentsList {
				contentMap := contentItem.(map[string]interface{})
				contents = append(contents, client.Content{
					Kind: contentMap["kind"].(string),
					Qty:  contentMap["qty"].(int),
				})
			}
		}
		opts.Contents = &contents
	}
	_, err = c.EntityUpdate(unitNumber, &opts)
	if err != nil {
		return diag.FromErr(err)
	}
	return resourceEntityRead(ctx, d, m)
}

func resourceEntityDelete(ctx context.Context, d *schema.ResourceData, m interface{}) diag.Diagnostics {
	c := m.(*client.FactorioClient)
	unitNumber, err := client.ParseUnitNumber(d.Id())
	if err != nil {
		return diag.FromErr(err)
	}
	err = c.EntityDelete(unitNumber)
	return diag.FromErr(err)
}
