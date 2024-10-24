using Distributed

# Configuration et initialisation
#-------------------------------

println("Chargement des adresses IP des workers depuis servers_ip.csv...")
file_content = read("servers_ip.csv", String)
ip_list = split(replace(file_content, "\"" => ""), ",")
machines = strip.(ip_list)
worker_addresses = map(ip -> "worker@" * ip, machines)

println("Configuration des workers sur les machines : $(worker_addresses)")

# Ajout des processus workers distants
addprocs(worker_addresses,
    exename="/home/worker/.juliaup/bin/julia",
    dir="/home/worker",
    tunnel=true
)

println("Nombre de workers disponibles : $(nworkers())")

# Définition des fonctions sur tous les workers
#-------------------------------------------
@everywhere begin
    function circle_equation(x::Float64, y::Float64)
        return (x - 1.0)^2 + (y - 2.0)^2 - 1.0
    end

    function find_points(x_range, y_range, tolerance)
        points = Tuple{Float64, Float64}[]
        grid_size = length(x_range) * length(y_range)
        worker_id = myid() - 1  # -1 car les workers commencent à 2
        println("Worker $worker_id traite une grille de $(length(x_range))×$(length(y_range)) = $grid_size points")
        
        for x in x_range
            for y in y_range
                if abs(circle_equation(x, y)) < tolerance
                    push!(points, (x, y))
                end
            end
        end
        return points
    end
end

# Paramètres du calcul
#--------------------
grid_size = 1000  # Nombre de points par dimension
x_range = range(-10.0, 10.0, length=grid_size)
y_range = range(-10.0, 10.0, length=grid_size)
tolerance = 0.01

# Affichage des informations sur la grille complète
#-----------------------------------------------
total_grid_size = length(x_range) * length(y_range)
println("\nInformations sur la grille complète :")
println("Dimensions : $(length(x_range))×$(length(y_range)) = $total_grid_size points")
println("Plage en x : [$(minimum(x_range)), $(maximum(x_range))]")
println("Plage en y : [$(minimum(y_range)), $(maximum(y_range))]")
println("Tolérance : $tolerance")

# Division du travail entre les workers
#------------------------------------
points_per_worker = div(length(x_range), nworkers())
println("\nRépartition du travail :")
println("Points sur l'axe x par worker : $points_per_worker")

# Création des sous-ensembles pour chaque worker
chunks = []
for worker_id in 1:nworkers()
    start_index = (worker_id - 1) * points_per_worker + 1
    end_index = min(worker_id * points_per_worker, length(x_range))
    worker_points = x_range[start_index:end_index]
    push!(chunks, worker_points)
    
    # Calcul de la taille de la grille pour ce worker
    worker_grid_size = length(worker_points) * length(y_range)
    println("Worker $worker_id : plage x[$(start_index):$(end_index)] = $(length(worker_points)) points")
    println("          taille de la sous-grille : $(length(worker_points))×$(length(y_range)) = $worker_grid_size points")
end

# Exécution distribuée
#--------------------
println("\nDémarrage du calcul distribué...")
@time begin
    results = @distributed (vcat) for chunk in chunks
        find_points(chunk, y_range, tolerance)
    end
end

# Affichage des résultats
#-----------------------
println("\nRésultats :")
println("Nombre total de points trouvés : $(length(results))")
if !isempty(results)
    println("Premiers points trouvés : $(results[1:min(5, length(results))])")

    println("\nVérification des premiers points :")
    for (i, (x, y)) in enumerate(results[1:min(5, length(results))])
        distance = sqrt((x - 1.0)^2 + (y - 2.0)^2)
        println("Point $i : ($x, $y), distance du centre = $distance")
    end
end

# Nettoyage
#----------
rmprocs(workers())
println("\nCalcul terminé et workers libérés.")