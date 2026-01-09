class Particle {
    fun Particle(position, velocity, mass=1.0) {
        this.position = List(position) // copy
        this.velocity = List(velocity)
        this.mass = mass
        this.force = [0.0, 0.0]
        this.max_height = position[1]
        this.distance_traveled = 0.0
    }

    fun apply_force(force) {
        this.force[0] += force[0]
        this.force[1] += force[1]
    }

    fun update(dt) {
        ax = this.force[0] / this.mass
        ay = this.force[1] / this.mass

        this.velocity[0] += ax * dt
        this.velocity[1] += ay * dt
        
        dx = this.velocity[0] * dt
        dy = this.velocity[1] * dt

        this.position[0] += dx
        this.position[1] += dy

        this.distance_traveled += Math.sqrt(dx^2 + dy^2)
        if (this.position[1] > this.max_height)
            this.max_height = this.position[1]
        
        this.force = [0.0, 0.0]
    }

    fun speed() = Math.sqrt(this.velocity[0]^2 + this.velocity[1]^2)
}

class ParticleSimulation {

    fun ParticleSimulation() {
        this.particles = []
    }

    fun add_particle(particle) {
        ~this.particles.append(particle)
    }

    fun step(dt) {
        for (p: this.particles) {
            gravity = [0.0, -9.81 * p.mass]
            ~p.apply_force(gravity)
            ~p.update(dt)
        }
    }

    fun run(steps, dt) {
        for (_: 0..steps)
            ~this.step(dt)
    }

    fun print_statistics() {
        for (i, p : Enumerate(this.particles)) {
            ~print(f"Particle {i}:")
            ~print(f"  Final position: ({p.position[0]}, {p.position[1]})")
            ~print(f"  Max height: {p.max_height}")
            ~print(f"  Distance traveled: {p.distance_traveled}")
            ~print(f"  Final speed: {p.speed()}")
            ~print()
        }
    }

    fun print_aggregate_statistics() {
        max_height = max([p.max_height : p = this.particles])
        max_distance = max([p.distance_traveled : p = this.particles])
        max_speed = max([p.speed() : p = this.particles])

        ~print("Aggregate statistics for all particles:")
        ~print(f"  Highest max height: {max_height}")
        ~print(f"  Longest distance traveled: {max_distance}")
        ~print(f"  Fastest final speed: {max_speed}")
    }
}

@main
fun main() {
    sim = ParticleSimulation()
    for (_: 0..1000)
        ~sim.add_particle(Particle([rand_int(0, 20), rand_int(0, 20)], [rand_int(0, 200), rand_int(0, 200)], rand_int(1, 100)))
    

    ~sim.run(steps=200, dt=0.05)
    ~sim.print_aggregate_statistics()
}