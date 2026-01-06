package client

import "strconv"

type Position struct {
	X float32 `json:"x"`
	Y float32 `json:"y"`
}

type UnitNumber uint32

func (u UnitNumber) String() string {
	return strconv.FormatUint(uint64(u), 10)
}

func ParseUnitNumber(unitNumberStr string) (UnitNumber, error) {
	unitNumber, err := strconv.ParseUint(unitNumberStr, 10, 32)
	if err != nil {
		return 0, err
	}
	return UnitNumber(unitNumber), nil
}

type Content struct {
	Kind string `json:"kind"`
	Qty  int    `json:"qty"`
}

type Entity struct {
	UnitNumber UnitNumber `json:"unit_number"`
	Surface    string     `json:"surface"`
	Name       string     `json:"name"`
	Position   Position   `json:"position"`
	Direction  Direction  `json:"direction"`
	Force      string     `json:"force"`
	Contents   []Content  `json:"contents,omitempty"`
}

// Looks up an entity by its unit_number
func (client *FactorioClient) EntityGet(unitNumber UnitNumber) (*Entity, error) {
	var entity Entity
	pEntity := &entity
	return pEntity, client.Read(
		"entity",
		map[string]interface{}{"unit_number": unitNumber},
		&pEntity)
}

// EntityQuery is used to find entities by attributes
type EntityQuery struct {
	Surface          *string   `json:"surface,omitempty"`
	Name             *string   `json:"name,omitempty"`
	Position         *Position `json:"position,omitempty"`
	PositionTolerance *float32  `json:"position_tolerance,omitempty"`
	Force            *string   `json:"force,omitempty"`
	Direction        *string   `json:"direction,omitempty"`
}

// EntityList finds entities matching the query criteria
func (client *FactorioClient) EntityList(query *EntityQuery) ([]Entity, error) {
	var results []Entity
	queryMap := make(map[string]interface{})
	if query != nil {
		if query.Surface != nil {
			queryMap["surface"] = *query.Surface
		}
		if query.Name != nil {
			queryMap["name"] = *query.Name
		}
		if query.Position != nil {
			queryMap["position"] = query.Position
		}
		if query.PositionTolerance != nil {
			queryMap["position_tolerance"] = *query.PositionTolerance
		}
		if query.Force != nil {
			queryMap["force"] = *query.Force
		}
		if query.Direction != nil {
			queryMap["direction"] = *query.Direction
		}
	}
	return results, client.List("entity", queryMap, &results)
}

// Corresponding to https://lua-api.factorio.com/latest/LuaSurface.html#LuaSurface.create_entity
type EntityCreateOptions struct {
	Surface                  string                 `json:"surface"` // eg. "nauvis"
	Name                     string                 `json:"name"`
	Position                 Position               `json:"position"`
	Direction                Direction              `json:"direction"`
	Force                    string                 `json:"force"` // eg. "player", "enemy", "neutral"
	EntitySpecificParameters map[string]interface{} `json:"entity_specific_parameters"`
	Contents                 []Content              `json:"contents,omitempty"`

	// Unimplemented
	/*
		target;
		source;
		fast_replace;
		player;
		spill;
		raise_built;
		create_build_effect_smoke;
		spawn_decorations;
		move_stuck_players;
		item;
	*/
}

func (client *FactorioClient) EntityCreate(opts *EntityCreateOptions) (*Entity, error) {
	var result Entity
	return &result, client.Create("entity", opts, &result)
}

// All params are optional
type EntityUpdateOptions struct {
	Direction *Direction  `json:"direction,omitempty"`
	Force     *string     `json:"force,omitempty"`
	Contents  *[]Content `json:"contents,omitempty"`
}

func (client *FactorioClient) EntityUpdate(unitNumber UnitNumber, opts *EntityUpdateOptions) (*Entity, error) {
	var result Entity
	return &result, client.Update(
		"entity",
		strconv.FormatUint(uint64(unitNumber), 10),
		opts,
		&result)
}

func (client *FactorioClient) EntityDelete(unitNumber UnitNumber) error {
	return client.Delete("entity", strconv.FormatUint(uint64(unitNumber), 10))
}
