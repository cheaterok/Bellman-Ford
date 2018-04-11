import argparse
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
    parser = argparse.ArgumentParser(description="Generate graph.")
    parser.add_argument('nodes', type=int, help="Number of nodes in graph.")
    parser.add_argument('output_file', help="Output file.")
    parser.add_argument('-s', '--start_node', type=int, help="Start node index.")
    parser.add_argument('-e', '--end_node', type=int, help="End node index.")
    parser.add_argument('-k', '--key', help="Seed for RNG.")

    args = parser.parse_args()

    if args.key:
        # Воспроизводимый рандом
        random.seed(args.key)

    matrix = generate_graph_matrix(args.nodes)

    start_node = args.start_node or 1
    end_node = args.end_node or (args.nodes - 1)
    save_graph_from_matrix(matrix, args.output_file, start_node, end_node)

    print(f"Graph generated and saved in {args.output_file}")

