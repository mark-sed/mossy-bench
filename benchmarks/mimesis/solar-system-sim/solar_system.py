"""
Simplified Simulation of Solar System
"""

import math
import matplotlib.pyplot as plt

# --------------------------------
# Constants (scaled units)
# --------------------------------
G = 4 * math.pi ** 2      # AU^3 / (year^2 * solar_mass)
DAY_TO_YEAR = 1.0 / 365.25

# --------------------------------
# Body definition
# --------------------------------
class Body:
    def __init__(self, name, mass, x, y, vx, vy):
        self.name = name
        self.mass = mass
        self.x = x
        self.y = y
        self.vx = vx
        self.vy = vy
        self.traj_x = []
        self.traj_y = []

# --------------------------------
# Solar system initialization
# --------------------------------
bodies = [
    Body("Sun",     1.0,        0,    0,     0,     0),

    Body("Mercury", 1.65e-7, 0.39,    0,     0, 10.1),
    Body("Venus",   2.45e-6, 0.72,    0,     0,  7.4),
    Body("Earth",   3.00e-6, 1.00,    0,     0,  6.28),
    Body("Mars",    3.30e-7, 1.52,    0,     0,  5.10),

    Body("Jupiter", 9.54e-4, 5.20,    0,     0,  2.75),
    Body("Saturn",  2.86e-4, 9.58,    0,     0,  2.03),
    Body("Uranus",  4.36e-5,19.20,    0,     0,  1.43),
    Body("Neptune", 5.15e-5,30.05,    0,     0,  1.14),
]

sun = bodies[0]

# --------------------------------
# Gravity calculation (N-body)
# --------------------------------
def compute_accelerations(bodies):
    accels = [(0.0, 0.0) for _ in bodies]

    for i, b1 in enumerate(bodies):
        ax = ay = 0.0
        for j, b2 in enumerate(bodies):
            if i == j:
                continue

            dx = b2.x - b1.x
            dy = b2.y - b1.y
            r2 = dx*dx + dy*dy
            r = math.sqrt(r2)

            ax += G * b2.mass * dx / r**3
            ay += G * b2.mass * dy / r**3

        accels[i] = (ax, ay)

    return accels

# --------------------------------
# Simulation
# --------------------------------
def simulate(days, dt_days=0.5):
    dt = dt_days * DAY_TO_YEAR
    steps = int(days / dt_days)

    for _ in range(steps):
        accels = compute_accelerations(bodies)

        for body, (ax, ay) in zip(bodies, accels):
            body.vx += ax * dt
            body.vy += ay * dt
            body.x += body.vx * dt
            body.y += body.vy * dt

            body.traj_x.append(body.x)
            body.traj_y.append(body.y)

# --------------------------------
# Plotting
# --------------------------------
def plot(bodies):
    plt.figure(figsize=(9, 9))

    for body in bodies:
        if body.name != "Sun":
            plt.plot(body.traj_x, body.traj_y, label=body.name)
            plt.scatter(body.traj_x[-1], body.traj_y[-1], s=12)

    plt.scatter(0, 0, color="yellow", s=250, label="Sun")

    plt.title("Simplified N-Body Solar System Simulation")
    plt.xlabel("AU")
    plt.ylabel("AU")
    plt.axis("equal")
    plt.grid(True)
    plt.legend()
    plt.show()

# --------------------------------
# Statistics
# --------------------------------
def print_statistics(bodies, dt_days=0.5):
    print("\n=== Simulation Statistics ===\n")

    for body in bodies:
        if body.name == "Sun":
            continue

        # ----------------------------
        # Distance traveled
        # ----------------------------
        dist = 0.0
        for i in range(1, len(body.traj_x)):
            dx = body.traj_x[i] - body.traj_x[i - 1]
            dy = body.traj_y[i] - body.traj_y[i - 1]
            dist += math.sqrt(dx * dx + dy * dy)

        # ----------------------------
        # Max distance from Sun
        # ----------------------------
        max_r = 0.0
        for x, y in zip(body.traj_x, body.traj_y):
            dx = x - sun.x
            dy = y - sun.y
            max_r = max(max_r, math.sqrt(dx * dx + dy * dy))

        # ----------------------------
        # Final speed
        # ----------------------------
        speed = math.sqrt(body.vx ** 2 + body.vy ** 2)

        # ----------------------------
        # Angular momentum
        # ----------------------------
        rx = body.x - sun.x
        ry = body.y - sun.y
        L = body.mass * (rx * body.vy - ry * body.vx)

        # ----------------------------
        # Orbital period detection
        # ----------------------------
        total_angle = 0.0
        prev_angle = math.atan2(
            body.traj_y[0] - sun.y,
            body.traj_x[0] - sun.x
        )

        orbit_days = None

        for i in range(1, len(body.traj_x)):
            angle = math.atan2(
                body.traj_y[i] - sun.y,
                body.traj_x[i] - sun.x
            )

            dtheta = angle - prev_angle

            # unwrap angle
            if dtheta < -math.pi:
                dtheta += 2 * math.pi
            elif dtheta > math.pi:
                dtheta -= 2 * math.pi

            total_angle += abs(dtheta)
            prev_angle = angle

            if total_angle >= 2 * math.pi:
                orbit_days = i * dt_days
                break

        # ----------------------------
        # Output
        # ----------------------------
        print(f"{body.name}:")
        print(f"  Total distance traveled: {dist:.2f} AU")
        print(f"  Max distance from Sun:  {max_r:.2f} AU")
        print(f"  Final speed:            {speed:.3f} AU/year")
        print(f"  Angular momentum:       {L:.3e}")

        if orbit_days is not None:
            print(f"  Orbital period:         {orbit_days:.1f} Earth days")
        else:
            print(f"  Orbital period:         not completed")

        print()

# --------------------------------
# Run everything
# --------------------------------
simulate(days=365 * 5)
#plot()
print_statistics(bodies, dt_days=0.5)