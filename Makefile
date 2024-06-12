mpi:
	nohup mpirun -np 4 Rscript main.R > output.txt 2> error.txt &
