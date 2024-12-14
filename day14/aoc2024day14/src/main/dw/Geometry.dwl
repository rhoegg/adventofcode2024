type Point = {
    x: Number,
    y: Number
}
type Velocity = Point

type Dimensions = {
    height: Number,
    width: Number
}

type RobotState = {
    position: Point,
    velocity: Velocity
}

fun move(p: Point, v: Velocity, t: Number): Point =
    {
        x: p.x + t * v.x,
        y: p.y + t * v.y
    }

fun move(r: RobotState, t: Number): RobotState =
    r update {
        case .position -> move(r.position, r.velocity, t)
    }

fun s(p: Point): String = "$(p.x),$(p.y)"
