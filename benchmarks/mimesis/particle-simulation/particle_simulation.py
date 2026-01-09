import math
import random

class Particle:
    def __init__(self, position, velocity, mass=1.0):
        self.position = list(position)  # [x, y]
        self.velocity = list(velocity)  # [vx, vy]
        self.mass = mass
        self.force = [0.0, 0.0]
        self.max_height = position[1]
        self.distance_traveled = 0.0

    def apply_force(self, force):
        self.force[0] += force[0]
        self.force[1] += force[1]

    def update(self, dt):
        # acceleration = force / mass
        ax = self.force[0] / self.mass
        ay = self.force[1] / self.mass

        # update velocity
        self.velocity[0] += ax * dt
        self.velocity[1] += ay * dt

        # update position
        dx = self.velocity[0] * dt
        dy = self.velocity[1] * dt
        self.position[0] += dx
        self.position[1] += dy

        # update statistics
        self.distance_traveled += math.sqrt(dx**2 + dy**2)
        if self.position[1] > self.max_height:
            self.max_height = self.position[1]

        # reset force
        self.force = [0.0, 0.0]

    def speed(self):
        return math.sqrt(self.velocity[0]**2 + self.velocity[1]**2)


class ParticleSimulation:
    def __init__(self):
        self.particles = []

    def add_particle(self, particle):
        self.particles.append(particle)

    def step(self, dt):
        for p in self.particles:
            # gravity
            gravity = [0.0, -9.81 * p.mass]
            p.apply_force(gravity)
            p.update(dt)

    def run(self, steps, dt):
        for _ in range(steps):
            self.step(dt)

    def print_statistics(self):
        for i, p in enumerate(self.particles):
            print(f"Particle {i}:")
            print(f"  Final position: ({p.position[0]:.2f}, {p.position[1]:.2f})")
            print(f"  Max height: {p.max_height:.2f}")
            print(f"  Distance traveled: {p.distance_traveled:.2f}")
            print(f"  Final speed: {p.speed():.2f}")
            print()

    def print_aggregate_statistics(self):
        max_height = max(p.max_height for p in self.particles)
        max_distance = max(p.distance_traveled for p in self.particles)
        max_speed = max(p.speed() for p in self.particles)

        print("Aggregate statistics for all particles:")
        print(f"  Highest max height: {max_height:.2f}")
        print(f"  Longest distance traveled: {max_distance:.2f}")
        print(f"  Fastest final speed: {max_speed:.2f}")

# Example usage
if __name__ == "__main__":
    sim = ParticleSimulation()
    for _ in range(1000):
        sim.add_particle(Particle([random.randint(0, 20), random.randint(0, 20)], [random.randint(0, 200), random.randint(0, 200)], random.randint(1, 100)))

    sim.run(steps=200, dt=0.05)
    sim.print_aggregate_statistics()