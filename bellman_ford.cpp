#include <limits>
#include <vector>
#include <iostream>
#include <fstream>
#include <sstream>
#include <chrono>
#include <algorithm>
#include <unistd.h>


using namespace std;

/*
 * a - номер первой вершины
 * b - номер второй вершины
 * cost - вес перехода
 *
 */

struct edge {
    int a, b, cost;
};

/*
 * n - кол-во вершин
 * m - кол-во рёбер
 * v - номер начальной вершины
 * t - номер конечной вершины
 *
 */

int n, m, v, t;
vector<edge> e;
const int INF = numeric_limits<int>::max();

vector<int> parseNextRow(istream& str)
{
    vector<int> result;
    string line;
    getline(str,line);

    stringstream lineStream(line);
    string cell;

    while(getline(lineStream, cell, ','))
        result.push_back(stoi(cell));

    return result;
}


void solve() {
    vector<int> d (n, INF);
    d[v] = 0;
    vector<int> p (n, -1);

    // ЗАСЕКАЕМ ВРЕМЯ
    auto startTime = std::chrono::high_resolution_clock::now();

    for (int i=0; i<n-1; i++) {
    #pragma omp parallel for
        for (int j=0; j<m; j++)
            if (d[e[j].a] < INF) {
                sleep(1);
                if (d[e[j].b] > d[e[j].a] + e[j].cost) {
                    d[e[j].b] = d[e[j].a] + e[j].cost;
                    p[e[j].b] = e[j].a;
                }
            }
    }

    auto stopTime = std::chrono::high_resolution_clock::now();
    std::chrono::duration<double> elapsed = stopTime - startTime;
    cout << "Time passed: " << elapsed.count() << endl;

    if (d[t] == INF)
        cout << "No path from " << v << " to " << t << "." << endl;
    else {
        vector<int> path;
        for (int cur=t; cur!=-1; cur=p[cur])
            path.push_back(cur);
        reverse (path.begin(), path.end());

        cout << "Path from " << v << " to " << t << ": " << endl;
        for (size_t i=0; i<path.size(); ++i)
            cout << path[i] << ' ';
        cout << endl;
    }
}


int main() {
    ifstream input_file;

    input_file.open("input", ios::out);
    if (!input_file.is_open()) {
        cout << "Could not open input file." << endl;
        return -1;
    }

    auto task_info = parseNextRow(input_file);
    n = task_info[0]; m = task_info[1]; v = task_info[2]; t = task_info[3];

    while (!input_file.eof()) {
        auto result = parseNextRow(input_file);
        e.push_back({result[0], result[1], result[2]});
    }

    solve();

    return 0;
}

