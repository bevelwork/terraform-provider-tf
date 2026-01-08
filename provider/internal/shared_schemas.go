package internal

import (
	"math"
	"strconv"
	"terraform-provider-factorio/client"

	"github.com/hashicorp/terraform-plugin-sdk/v2/helper/schema"
)

func shouldSuppressDiffPosition(k, old, new string, d *schema.ResourceData) bool {
	oldF, errOld := strconv.ParseFloat(old, 64)
	newF, errNew := strconv.ParseFloat(new, 64)
	
	// If parsing failed, don't suppress (let Terraform handle it)
	if errOld != nil || errNew != nil {
		return false
	}
	
	// If values are the same, suppress diff
	if oldF == newF {
		return true
	}
	
	// Check if the absolute difference is small (within 0.6 to account for .5 positions)
	// This handles cases where Factorio snaps .5 positions to integers or vice versa
	diff := math.Abs(oldF - newF)
	if diff < 0.6 {
		// Values are within the same tile, suppress diff
		return true
	}
	
	// Also check if both values round to the same integer
	// This handles cases like -37.5 vs -37 (Factorio snaps .5 to integer)
	// Use a small epsilon to handle floating point precision issues
	const epsilon = 0.001
	oldRounded := math.Round(oldF)
	newRounded := math.Round(newF)
	if math.Abs(oldRounded - newRounded) < epsilon {
		return true
	}
	
	return false
}

func integerPositionSchema(base *schema.Schema) *schema.Schema {
	posSchema := positionSchema(base)
	innerSchema := posSchema.Elem.(*schema.Resource).Schema
	innerSchema["x"].DiffSuppressFunc = shouldSuppressDiffPosition
	innerSchema["y"].DiffSuppressFunc = shouldSuppressDiffPosition
	return posSchema
}

func positionSchema(base *schema.Schema) *schema.Schema {
	base.Type = schema.TypeList
	base.Elem = &schema.Resource{
		Schema: map[string]*schema.Schema{
			"x": {
				Type:     schema.TypeFloat,
				Optional: base.Optional,
				Required: base.Required,
				Computed: base.Computed,
				ForceNew: base.ForceNew,
			},
			"y": {
				Type:     schema.TypeFloat,
				Optional: base.Optional,
				Required: base.Required,
				Computed: base.Computed,
				ForceNew: base.ForceNew,
			},
		},
	}
	if !base.Computed {
		base.MinItems = 1
		base.MaxItems = 1
	}
	return base
}

func validateDirection(i interface{}, s string) ([]string, []error) {
	_, err := client.ParseDirection(i.(string))
	if err != nil {
		return nil, []error{err}
	}
	return nil, nil
}

func directionSchema(base *schema.Schema) *schema.Schema {
	base.Type = schema.TypeString
	base.ValidateFunc = validateDirection
	return base
}
