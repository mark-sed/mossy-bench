"""
Model of a simple Neural Network, that takes 5 values and is supposed to
output (predict) the second value.
"""

import random

def relu(x):
    return x if x > 0 else 0.0

def relu_deriv(x):
    return 1.0 if x > 0 else 0.0


class TinyNN:
    def __init__(self, lr=0.01):
        self.lr = lr

        # input (5) -> hidden (4)
        self.w1 = [[random.uniform(-1, 1) for _ in range(5)] for _ in range(4)]
        self.b1 = [random.uniform(-1, 1) for _ in range(4)]

        # hidden (4) -> output (1)
        self.w2 = [random.uniform(-1, 1) for _ in range(4)]
        self.b2 = random.uniform(-1, 1)

    def forward(self, x):
        self.h = []
        for i in range(4):
            s = self.b1[i]
            for j in range(5):
                s += self.w1[i][j] * x[j]
            self.h.append(relu(s))

        y_hat = self.b2
        for i in range(4):
            y_hat += self.w2[i] * self.h[i]

        return y_hat

    def train(self, x, y):
        y_hat = self.forward(x)
        error = y_hat - y

        # Output layer update
        for i in range(4):
            self.w2[i] -= self.lr * 2 * error * self.h[i]
        self.b2 -= self.lr * 2 * error

        # Hidden layer update
        for i in range(4):
            dh = 2 * error * self.w2[i]
            dh *= relu_deriv(self.h[i])

            for j in range(5):
                self.w1[i][j] -= self.lr * dh * x[j]
            self.b1[i] -= self.lr * dh

        return error * error


# -------- Training --------
net = TinyNN(lr=0.01)

MAX_EPOCHS = 5000
for epoch in range(MAX_EPOCHS):
    x = [float(random.randint(0, 1)) for _ in range(5)]
    y = x[1]

    loss = net.train(x, y)

    if epoch % (MAX_EPOCHS//10) == 0:
        print(f"epoch {epoch}, loss {loss:.6f}")

# -------- Test --------
test = [0.0, 1.0, 0.0, 0.0, 0.0]
pred = net.forward(test)

print("\nTest input :", test)
print("Prediction :", pred)
print("Expected   :", test[1])