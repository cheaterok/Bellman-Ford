'{:dependencies [[org.clojure/clojure "1.8.0"]
                 [org.clojure/data.csv "0.1.4"]]}

(require '[clojure.data.csv :as csv]
         '[clojure.java.io :as io])

(defn edges-for-nodes [nodes-num edges]
  "Список граней для каждой вершины"
  (defn edges-for-node [node-index]
    "Список граней, входящих в вершину с указанным индексом"
    ; Замыкаем edges
    (filter #(= (:b %) node-index) edges))
  
  (->> (range nodes-num) (map edges-for-node)))

(defn relax-nodes [edges-list nodes]
  "В nodes пары (список длин до каждой вершины из нулевой, 
  предыдущие вершины в коротком пути для каждой вершины"

  (defn calc-cost [edge]
    "Возвращает путь до ноды (старый, если новый длиннее)"
    ; Замыкаем nodes
    (let [[start-cost _] (get nodes (:a edge))
        [end-cost old-parent] (get nodes (:b edge))]
      (if (< (+ start-cost (:cost edge)) end-cost)
        [(+ start-cost (:cost edge)) (:a edge)]
        [end-cost old-parent])))

  (defn relax-each [node edges-for-node]
    "Пытается удешевить путь до вершины на основе граней,
    входящих в эту вершину"
    ; Пропускаем путь до начальной вершины
    (if (zero? (first node))
      [0 0]
      (apply min-key first (map calc-cost edges-for-node))))

  (into [] (pmap relax-each nodes edges-list)))

(defn bellman-ford [nodes-num start-node edges-list]
  "Алгоритм Беллмана-Форда"
  (let [inf-src (repeat Double/POSITIVE_INFINITY)] ; Бесконечный генератор бесконечности
    (->>
      ; Список путей (0 до первой вершины и бесконечности для остальных
      (map vector
        (flatten [(take start-node inf-src) 0 (take (- nodes-num start-node) inf-src)])
        (take nodes-num (repeat 0)))
      (into [])
      (iterate (partial relax-nodes edges-list))
      (take (- nodes-num 1))
      last
      time)))

(defn restore-shortest-path [paths start-node end-node]
  "Восстанавливает кратчайший путь от начальной до конечной вершины"
  (defn get-next [path-list]
    (let [next-val (get paths (last path-list))
          path-list (conj path-list next-val)]
      (if (= next-val start-node)
        path-list
        (get-next path-list))))
  ; Формируем список путей и не забываем добавить финишную ноду в конец
  (conj (->> [(get paths end-node)] get-next reverse (into [])) end-node))

(defn read-graph [filename]
  "Считывает граф из .csv файла (см. формат в README)"
  (with-open [reader (io/reader filename)]
    (as-> (doall (csv/read-csv reader)) it
      (map #(map read-string %) it)
      (concat (first it) (->> (rest it) (map zipmap (repeat [:a :b :cost])) vector)))))

; Типа main
(let [[nodes-num _ start-node end-node edges] (read-graph (first *command-line-args*))
      edges-list (edges-for-nodes nodes-num edges)]

  (def result (bellman-ford nodes-num start-node edges-list))
  (def nodes-cost (into [] (map first result)))
  (def paths (into [] (map second result)))

  (def shortest-path-cost (get nodes-cost end-node))
  (def shortest-path (restore-shortest-path paths start-node end-node))

  (println (str "Shortest path from " start-node " to " end-node " is:"))
  (println shortest-path)
  (println (str "Shortest path cost = " shortest-path-cost)))
