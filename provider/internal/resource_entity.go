package internal

import (
	"context"
	"math"

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
			"recipe": {
				Type:        schema.TypeList,
				Optional:    true,
				MaxItems:    1,
				Description: "Recipe to set for crafting entities (e.g., assembly machines)",
				Elem: &schema.Resource{
					Schema: map[string]*schema.Schema{
						"kind": {
							Type:        schema.TypeString,
							Required:    true,
							Description: "The recipe name (e.g., 'iron-gear-wheel', 'copper-cable')",
						},
					},
				},
			},
			"force_replace": {
				Type:        schema.TypeBool,
				Optional:    true,
				Default:     false,
				Description: "If true, automatically remove any non-Terraform-managed entities that collide with this resource's position.",
			},
		},
	}
}

// tileToCenterPosition converts tile coordinates to center-based coordinates.
// In Factorio, entities are positioned by their center. If the user provides
// integer tile coordinates (e.g., x=10, y=20), we convert them to center
// coordinates (x=10.5, y=20.5) for a 1x1 entity. If the coordinates are
// already non-integer, we assume they're already center coordinates.
func tileToCenterPosition(pos client.Position) client.Position {
	const epsilon = 0.001 // Small epsilon for floating point comparison
	
	// Check if x is an integer (or very close to one)
	xIsInteger := math.Abs(float64(pos.X)-math.Round(float64(pos.X))) < epsilon
	yIsInteger := math.Abs(float64(pos.Y)-math.Round(float64(pos.Y))) < epsilon
	
	centerPos := pos
	if xIsInteger {
		centerPos.X = pos.X + 0.5
	}
	if yIsInteger {
		centerPos.Y = pos.Y + 0.5
	}
	
	return centerPos
}

// normalizePosition normalizes positions between Factorio's actual position and
// Terraform state to prevent drift. Factorio may snap positions (e.g., .5 to integer),
// so we need to handle both cases:
// 1. If Factorio returns integer and state has .5: use Factorio's integer (it was snapped)
// 2. If Factorio returns .5 and state has integer: use state's integer (user's original intent)
// 3. Otherwise: use Factorio's position (source of truth)
func normalizePosition(factorioPos client.Position, statePos *client.Position) client.Position {
	const epsilon = 0.001 // Small epsilon for floating point comparison
	const centerOffset = 0.5
	
	result := factorioPos
	
	// Check if Factorio position is a center position (ends in .5) or integer
	xFactorioDiff := math.Abs(float64(factorioPos.X) - math.Round(float64(factorioPos.X)))
	xFactorioIsCenter := math.Abs(xFactorioDiff - centerOffset) < epsilon
	xFactorioIsInteger := xFactorioDiff < epsilon
	
	yFactorioDiff := math.Abs(float64(factorioPos.Y) - math.Round(float64(factorioPos.Y)))
	yFactorioIsCenter := math.Abs(yFactorioDiff - centerOffset) < epsilon
	yFactorioIsInteger := yFactorioDiff < epsilon
	
	// If we have state position, check for mismatches
	if statePos != nil {
		xStateDiff := math.Abs(float64(statePos.X) - math.Round(float64(statePos.X)))
		xStateIsInteger := xStateDiff < epsilon
		xStateIsCenter := math.Abs(xStateDiff - centerOffset) < epsilon
		
		yStateDiff := math.Abs(float64(statePos.Y) - math.Round(float64(statePos.Y)))
		yStateIsInteger := yStateDiff < epsilon
		yStateIsCenter := math.Abs(yStateDiff - centerOffset) < epsilon
		
		// Case 1: Factorio returned integer, state has .5 - Factorio snapped it, use Factorio's integer
		// This prevents drift when Factorio snaps .5 positions to integers
		if xFactorioIsInteger && xStateIsCenter {
			result.X = factorioPos.X
		} else if xFactorioIsCenter && xStateIsInteger {
			// Case 2: Factorio returned .5, state has integer - user provided integer, use state's integer
			// This preserves user's original integer coordinates
			result.X = statePos.X
		}
		// Otherwise: use Factorio's position as-is (source of truth)
		
		if yFactorioIsInteger && yStateIsCenter {
			result.Y = factorioPos.Y
		} else if yFactorioIsCenter && yStateIsInteger {
			result.Y = statePos.Y
		}
	} else {
		// No state position - if Factorio returned center position, convert to integer
		// This handles the first read after creation where user might have provided integers
		// that were converted to .5, but Factorio snapped them back
		if xFactorioIsCenter {
			result.X = float32(math.Trunc(float64(factorioPos.X)))
		}
		if yFactorioIsCenter {
			result.Y = float32(math.Trunc(float64(factorioPos.Y)))
		}
	}
	
	return result
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
	// Convert tile coordinates to center coordinates if needed
	rawPosition := client.Position{
		X: float32(d.Get("position.0.x").(float64)),
		Y: float32(d.Get("position.0.y").(float64)),
	}
	position := tileToCenterPosition(rawPosition)
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

	// Extract recipe
	var recipe *client.Recipe
	if recipeList, ok := d.Get("recipe").([]interface{}); ok && len(recipeList) > 0 {
		recipeMap := recipeList[0].(map[string]interface{})
		recipe = &client.Recipe{
			Kind: recipeMap["kind"].(string),
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
		
		// Check if recipe changed (compare current vs desired)
		currentRecipeKind := ""
		if e.Recipe != nil {
			currentRecipeKind = e.Recipe.Kind
		}
		desiredRecipeKind := ""
		if recipe != nil {
			desiredRecipeKind = recipe.Kind
		}
		if currentRecipeKind != desiredRecipeKind {
			updateOpts.Recipe = recipe
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
		opts.Recipe = recipe
		
		// Set force_replace if specified
		if forceReplace, ok := d.Get("force_replace").(bool); ok && forceReplace {
			opts.ForceReplace = &forceReplace
		}

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

func flattenPosition(pos client.Position, d *schema.ResourceData) []map[string]float64 {
	// Get current state position if it exists
	var statePos *client.Position
	if positionList, ok := d.Get("position").([]interface{}); ok && len(positionList) > 0 {
		if positionMap, ok := positionList[0].(map[string]interface{}); ok {
			statePos = &client.Position{
				X: float32(positionMap["x"].(float64)),
				Y: float32(positionMap["y"].(float64)),
			}
		}
	}
	
	// Normalize position to prevent drift between Factorio's actual position and state
	normalizedPos := normalizePosition(pos, statePos)
	
	flat := make(map[string]float64)
	flat["x"] = float64(normalizedPos.X)
	flat["y"] = float64(normalizedPos.Y)
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

func flattenRecipe(recipe *client.Recipe) []map[string]interface{} {
	if recipe == nil {
		return []map[string]interface{}{}
	}
	return []map[string]interface{}{
		{
			"kind": recipe.Kind,
		},
	}
}

func writeEntityToResourceData(e *client.Entity, d *schema.ResourceData) diag.Diagnostics {
	var diags diag.Diagnostics
	writeAttributeToResource(&diags, d, "unit_number", e.UnitNumber)
	writeAttributeToResource(&diags, d, "surface", e.Surface)
	writeAttributeToResource(&diags, d, "name", e.Name)
	writeAttributeToResource(&diags, d, "position", flattenPosition(e.Position, d))
	writeAttributeToResource(&diags, d, "direction", e.Direction.String())
	writeAttributeToResource(&diags, d, "force", e.Force)
	writeAttributeToResource(&diags, d, "contents", flattenContents(e.Contents))
	writeAttributeToResource(&diags, d, "recipe", flattenRecipe(e.Recipe))
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
	if d.HasChange("recipe") {
		var recipe *client.Recipe
		if recipeList, ok := d.Get("recipe").([]interface{}); ok && len(recipeList) > 0 {
			recipeMap := recipeList[0].(map[string]interface{})
			recipe = &client.Recipe{
				Kind: recipeMap["kind"].(string),
			}
		}
		opts.Recipe = recipe
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
