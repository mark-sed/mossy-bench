d"""
Simplified Simulation of Solar System
"""

import math.atan

// Constants (scaled units)
G = 4.0 * Math.pi ^ 2 // AU ^ 3 / (year ^ 2 * solar_mass)
DAY_TO_YEAR = 1.0 / 365.25

// Body
class Body {
    fun Body(name, mass, x, y, vx, vy) {
        this.name = name
        this.mass = mass
        this.x = x
        this.y = y
        this.vx = vx
        this.vy = vy
        this.traj_x = []
        this.traj_y = []
    }
}

// Initialization
bodies = [
    Body("Sun",     1.0,      0.0,    0.0,     0.0,   0.0),

    Body("Mercury", 1.65e-7, 0.39,    0.0,     0.0,  10.1),
    Body("Venus",   2.45e-6, 0.72,    0.0,     0.0,  7.4),
    Body("Earth",   3.00e-6, 1.00,    0.0,     0.0,  6.28),
    Body("Mars",    3.30e-7, 1.52,    0.0,     0.0,  5.10),

    Body("Jupiter", 9.54e-4, 5.20,    0.0,     0.0,  2.75),
    Body("Saturn",  2.86e-4, 9.58,    0.0,     0.0,  2.03),
    Body("Uranus",  4.36e-5,19.20,    0.0,     0.0,  1.43),
    Body("Neptune", 5.15e-5,30.05,    0.0,     0.0,  1.14),
]

sun = bodies[0]

// Gravity calculation for N bodies
fun compute_accelerations(bodies) {
    accels = [[0.0, 0.0] : _ = bodies]

    // TODO: temp fix for bug
    bod2 = List(bodies)
    for (i, b1 : Enumerate(bodies)) {
        ax = 0.0
        ay = 0.0
        for (j, b2 : Enumerate(bod2)) {
            if (i == j)
                continue

            dx = b2.x - b1.x
            dy = b2.y - b1.y
            r2 = dx*dx + dy*dy
            r = Math.sqrt(r2)

            ax += G * b2.mass * dx / r^3
            ay += G * b2.mass * dy / r^3
        }
        accels[i] = [ax, ay]
    }
    return accels
}

fun simulate(days, dt_days=0.5) {
    dt = dt_days * DAY_TO_YEAR
    steps = Int(days / dt_days)

    for (_ : 0..steps) {
        accels = compute_accelerations(bodies)

        for (body, a : zip(bodies, accels)) {
            ax = a[0]
            ay = a[1]
            body.vx += ax * dt
            body.vy += ay * dt
            body.x += body.vx * dt
            body.y += body.vy * dt
            ~body.traj_x.append(body.x)
            ~body.traj_y.append(body.y)
        }
    }
}

fun atan2(y, x) {
    if (x > 0)
        return atan(y / x)

    if (x < 0 and y >= 0)
        return atan(y / x) + Math.pi

    if (x < 0 and y < 0)
        return atan(y / x) - Math.pi

    if (x == 0 and y > 0)
        return Math.pi / 2

    if (x == 0 and y < 0)
        return -Math.pi / 2

    // x == 0 and y == 0
    return 0.0
}

fun print_statistics(bodies, dt_days=0.5) {
    ~print("\n=== Simulation Statistics ===\n")

    for (body : bodies) {
        if (body.name == "Sun")
            continue
        
        // Distance traveled
        dist = 0.0
        for (i : 1..body.traj_x.length()) {
            dx = body.traj_x[i] - body.traj_x[i - 1]
            dy = body.traj_y[i] - body.traj_y[i - 1]
            dist += Math.sqrt(dx * dx + dy * dy)
        }

        // Max distance from Sun
        max_r = 0.0
        for (x, y : zip(body.traj_x, body.traj_y)) {
            dx = x - sun.x
            dy = y - sun.y
            max_r = max([max_r, Math.sqrt(dx*dx + dy*dy)])
        }

        // Final speed
        speed = Math.sqrt(body.vx ^ 2.0 + body.vy ^ 2.0)

        // Angular momentum
        rx = body.x - sun.x
        ry = body.y - sun.y
        L = body.mass * (rx * body.vy - ry * body.vx)

        // Orbital period detected
        total_angle = 0.0
        prev_angle = atan2(
            body.traj_y[0] - sun.y,
            body.traj_x[0] - sun.x
        )

        orbit_days = nil

        for (i: 1..body.traj_x.length()) {
            angle = atan2(
                body.traj_y[i] - sun.y,
                body.traj_x[i] - sun.x
            )

            dtheta = angle - prev_angle

            // unwrap anfle
            if (dtheta < -Math.pi)
                dtheta += 2 * Math.pi
            else if (dtheta > Math.pi)
                dtheta -= 2 * Math.pi

            total_angle += Math.abs(dtheta)
            prev_angle = angle

            if (total_angle >= 2 * Math.pi) {
                orbit_days = i * dt_days
                break
            }
        }

        // Output
        ~print(f"{body.name}:")
        ~print(f"  Total distance traveled: {dist} AU")
        ~print(f"  Max distance from Sun:   {max_r} AU")
        ~print(f"  Final speed:             {speed} AU/year")
        ~print(f"  Angular momentum:        {L}")

        if (orbit_days != nil)
            ~print(f"  Orbital period:          {orbit_days} Earth days")
        else
            ~print(f"  Orbital period:          not completed")

        ~print()
    }
}

// Run simulation for 5 years
~simulate(days=365 * 5)
~print_statistics(bodies, dt_days=0.5)