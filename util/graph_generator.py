import csv
import random


class Matrix:

    def __init__(self, mat, nodes_num, connections_num):
        self.mat = mat
        self.nodes_num = nodes_num
        self.connections_num = connections_num


def generate_graph_matrix(n):
    # Матрица n*n
    mat = [[0 for _ in range(n)] for _ in range(n)]

    connections = 0

    for i in range(n):
        for j in range(n):
            if i == j:
                continue
            connection_weight = None
            if random.random() <= 1/5:
                connections += 1
                mat[i][j]= random.randint(1, 10)

    return Matrix(mat, n, connections)


def save_graph_from_matrix(matrix, file, start, end):
    with open(file, 'wt', newline='') as csv_file:
        writer = csv.writer(csv_file)
        writer.writerow([matrix.nodes_num, matrix.connections_num, start, end])
        mat = matrix.mat
        for i in range(matrix.nodes_num):
            for j in range(matrix.nodes_num):
                if mat[i][j] != 0:
                    writer.writerow([i, j, mat[i][j]])


if __name__ == '__main__':
    # Воспроизводимый рандом
    random.seed("random-key")

    matrix = generate_graph_matrix(100)
    save_graph_from_matrix(matrix, 'graph.csv', 4, 99)

