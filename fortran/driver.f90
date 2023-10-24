! The main program which runs our driver test case potentials
! ./driver.x -h localhost -p 31415

program driver
    use f90sockets, only : open_socket, writebuffer, readbuffer
    use, intrinsic :: iso_c_binding

    implicit none

    ! socket variables
    integer, parameter :: msglen=12   ! length of the headers of the driver/wrapper communication protocol
    integer socket, inet, port        ! socket id & address of the server
    character(len=1024) :: host

    ! command line parsing
    character(len=1024) :: cmdbuffer
    logical :: hflag=.false., pflag=.false.

    ! socket communication buffers
    character(len=12) :: header
    logical :: isinit=.false.   ! The driver has been initialised by the server
    logical :: hasdata=.true.   ! The driver has finished computing and can send data to server

    ! data to send and receive 
    real(kind=4) :: actionbuffer(4), state(4) 
    real(kind=4) :: statebuffer(4) !buff用来存转换形状的state,这里state是一维可以不转换。
    
    ! helper varivables
    integer :: i, j, dims
    integer :: time1, time2

    ! intialize defaults
    inet = 1
    host = "192.168.211.107"//achar(0)
    port = 31415
    
    ! read command arguments
    if (mod(command_argument_count(), 2) /= 0) then
        call helpmessage
        stop "ended"
    end if

    write(*,*) " driver - connecting to host ", trim(host), " on port ", port, " using an internet socket."

    state = (/0.0, 1.0, 2.0, 3.0/)
    write(*,*) "Initial state is :", 0, state
    
    ! open port
    call open_socket(socket, inet, port, host)

    call system_clock(time1)
    
    do i=1,9
        write(*,*) "state transmitted:",i ,state

        ! 转换state形状并发送给python
        statebuffer = reshape(state, [size(state)])   ! flatten data
        call writebuffer(socket, statebuffer, size(statebuffer))

        ! 从python读取返回的action
        call readbuffer(socket, actionbuffer, size(actionbuffer))
        write(*,*) "Received action  :",i ,actionbuffer

        ! 根据action来改变state
        do j =  1, size(state)
            ! state(j) = state(j) + actionbuffer(1) / 100000.0
            state(j) = actionbuffer(j) + 1.
        enddo
    enddo 

    call system_clock(time2)
    write(*,*) 'time used: ', (time2 - time1) / 100000.0, 's'

contains

    subroutine do_something(a)
        real(kind=4), intent(inout) :: a(:,:)

        !call sleep(5)
        a = a*2
    end subroutine do_something

    subroutine helpmessage ! Help banner
        write(*,*) " syntax: driver.x -h hostname -p port "
    end subroutine helpmessage

end program
