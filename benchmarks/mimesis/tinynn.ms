d"""
Model of a simple Neural Network, that takes 5 values and is supposed to
output (predict) the second value.
"""

fun relu(x) = x > 0 ? x : 0.0

fun relu_deriv(x) = x > 0 ? 1.0 : 0.0

class TinyNN {

    fun TinyNN(lr=0.01) {
        this.lr = lr
        // 5 inputs, 4 hidden
        this.w1 = [[rand_float(-1, 1) : _ = 0..5] : __ = 0..4]
        this.b1 = [rand_float(-1, 1) : _ = 0..4]
        // 4 hidden -> output 1
        this.w2 = [rand_float(-1, 1) : _ = 0..4]
        this.b2 = rand_float(-1, 1)
    }

    fun forward(x) {
        this.h = []
        for (i: 0..4) {
            s = this.b1[i]
            for (j: 0..5) {
                s += this.w1[i][j] * x[j]
            }
            ~this.h.append(relu(s))
        }

        y_hat = this.b2
        for (i: 0..4) {
            y_hat += this.w2[i] * this.h[i]
        }

        return y_hat
    }

    fun train(x, y) {
        y_hat = this.forward(x)
        error = y_hat - y

        // Output layer update
        for (i: 0..4) {
            this.w2[i] -= this.lr * 2 * error * this.h[i]
        }
        this.b2 -= this.lr * 2 * error

        // Hidden layer update
        for (i: 0..4) {
            dh = 2 * error * this.w2[i]
            dh *= relu_deriv(this.h[i])

            for (j: 0..5) {
                this.w1[i][j] -= this.lr * dh * x[j]
            }

            this.b1[i] -= this.lr * dh

            return error * error
        }
    }
}

net = TinyNN(lr=0.01)

// Train
MAX_EPOCHS = 5000
for (epoch: 0..MAX_EPOCHS) {
    x = [Float(rand_int(0, 1)) : _ = 0..5]
    // Predict 2nd value
    y = x[1]

    loss = net.train(x, y)

    if (epoch % (MAX_EPOCHS/10) == 0 || epoch == MAX_EPOCHS) {
        ~print(f"epoch {epoch}, loss {loss}")
    }
}

// Test
test = [0.0, 1.0, 0.0, 0.0, 0.0]
pred = net.forward(test)

~print("\nTest input: ", test)
~print("Prediction :", pred)
~print("Expected   :", test[1])
