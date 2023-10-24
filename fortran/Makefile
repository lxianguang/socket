# Makefile for icc ifort 

.PHONY: all modules clean

#FLAGS = -g -O3
FLAGS = 
CC = gcc 
FC = gfortran

all: driver.x

sockets.o: sockets.c 
	$(CC) $(FLAGS) -c sockets.c 

driver.x: sockets.o fsockets.o driver.o 
	$(FC) $(FLAGS) -o driver.x $^

%.o: %.f90
	$(FC) $(FLAGS) -c $< 

clean:
	rm -f *.o *.mod *.x