# Makefile нового поколения

INLEIN_URL="https://github.com/hypirion/inlein/releases/download/0.2.0/inlein"

CPP_FILE="src/bellman_ford.cpp"
EXECUTABLE="build/bellman_ford"
EXECUTABLE_PAR="${EXECUTABLE}_parallel"

CLJ_FILE="src/bellman_ford.clj"
CLJ_PAR_FILE="src/bellman_ford_par.clj"

GRAPH_GENERATOR="util/graph_generator.py"

DEFAULT_GRAPH="input.csv"
GRAPH_1="build/graph_1.csv"
GRAPH_2="build/graph_2.csv"
GRAPH_3="build/graph_3.csv"
GRAPH_4="build/graph_4.csv"

GRAPHS_LIST=( $DEFAULT_GRAPH $GRAPH_1 $GRAPH_2 $GRAPH_3 $GRAPH_4 )

function build {
    # Если нет Inlein - качаем Inlein
    if [ ! -f ./inlein ]; then
        echo "Downloading Inlein"
        wget $INLEIN_URL
        chmod 755 inlein
    fi
    
    mkdir build

    echo "Compiling C++"
    # Параллельно собираем плюсовые прожки
    g++ $CPP_FILE -o $EXECUTABLE &
    g++ $CPP_FILE -o $EXECUTABLE_PAR -fopenmp &
    wait

    # Генерим графики 
    # Они одинаковые от билда к билду, если скрипт запускается с одинаковыми параметрами 
    # и одним и тем же ключом
    echo "Generating graphs"
    python $GRAPH_GENERATOR 100 0.05 $GRAPH_1 -k first &
    python $GRAPH_GENERATOR 100 0.5 $GRAPH_2 -k second &
    python $GRAPH_GENERATOR 1000 0.05 $GRAPH_3 -k third &
    python $GRAPH_GENERATOR 1000 0.5 $GRAPH_4 -k fourth &
    wait
}

function run {
    echo "Solving with C++:"; echo
    for graph in ${GRAPHS_LIST[@]}
    do
        echo $graph;echo
        echo "Sequential:"
        ./$EXECUTABLE $graph
        echo "Parallel:"
        ./$EXECUTABLE_PAR $graph
        echo
    done

    echo "Solving with Clojure:"; echo
    for graph in ${GRAPHS_LIST[@]}
    do
        echo $graph;echo
        echo "Sequential:"
        ./inlein $CLJ_FILE $graph
        echo "Parallel:"
        ./inlein $CLJ_PAR_FILE $graph
        echo
    done
}

function clean {
    rm -r build
}

# Запускаем build или clean, в зависимости от аргумента
# Или ругаемся, если там ни то, ни другое
if [ "$1" == "build" ] || [ "$1" == "run" ] || [ "$1" == "clean" ]; then
    $1
else
    echo "Options: build | run | clean"
fi

