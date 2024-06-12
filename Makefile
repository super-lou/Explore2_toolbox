run:
	nohup mpirun -np 4 Rscript main.R > output.txt 2> error.txt &

clean:
	rm -rf tmp_*
	rm output.txt
	rm error.txt

find:
	ps aux | grep mpirun

kill:
	ps aux | grep '[m]pirun' | awk '{print $2}' | xargs kill
