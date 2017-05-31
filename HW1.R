#' BMI Calculator
#'
#' @param w_kg #weight in kilograms
#' @param h_m  #height in meters
#'
#' @return #returns your BMI index
#' @export
#'
#' @examples
#' BMI(72,1.77) -> 22.98
BMI = function(w_kg, h_m) {
  if(w_kg<0 || h_m<0) stop("Error: Arguments need to be positive", call = F)
  return(w_kg/h_m^2)
}


#' Area of Parallelogram
#'
#' @param l #length of parallelogram
#' @param w #width of parallelogram
#' @param ang #angle in radians of interior angle
#'
#' @return #area of parallelogram
#' @export
#'
#' @examples
#' area_par(2) = 4  --assumes you mean square
#' area_par(4,4, pi/2) = 16 --rhoumbus
#' area_par(4,2, pi/3) = 6.928 --parallelogram
area_par = function(l, w = l, ang = pi/2) {
  return(l*w*sin(ang))
}

#' Fibonacci sequence
#'
#' @param n #number of elements in fibonacci sequence
#'
#' @return #returns fibonacci sequence
#' @export
#'
#' @examples
#' fib(5) -> [0,1,1,2,3]
#' fb(7) -> [0,1,1,2,3,5,8]
fib = function(n) {
  if(n<3) stop("Error: Number too small choose a number greater than 2", call=F)
  fib = c(0,1)
  for( i in 3:n) {
    fib[i] = fib[i-1]+fib[i-2]
  }
  return(fib)
}


#' 99 bottles of beer (Generalized)
#'
#' @param num #number of vessels
#' @param vessel #type of vessel
#' @param liquid  #liquid in vessel
#' @param surface  #location of vessel
#'
#' @return #generalized lyrics of song
#' @export
#'
#' @examples
#' rep_song(2,"bottles","beer", "wall") ->  
#' 2 bottles  of beer on the wall, 2 bottles of beer
#' Take one down pass it around, 1 bottles  of beer on the wall
#' 1 bottles  of beer on the wall, 1 bottles of beer
#' Take one down pass it around, 0 bottles  of beer on the wall
#' No more bottles of beer on the wall, no more bottles of beer
#' Go to the store and buy some more, 2 bottles of beer on the wall
#' 
rep_song = function(num, vessel, liquid, surface){
  max = num
  while(num > 0) {
    cat(sprintf("%d %s  of %s on the %s, %d %s of %s\n", num, vessel, liquid, surface, num, vessel, liquid))
    num = num-1
    cat(sprintf("Take one down pass it around, %d %s  of %s on the %s\n",num, vessel, liquid, surface))
  }
  cat(sprintf("No more %s of %s on the %s, no more %s of %s\n", vessel, liquid, surface, vessel, liquid))
  cat(sprintf("Go to the store and buy some more, %d %s of %s on the %s", max, vessel, liquid, surface))
}

#' Ellipse Perimeter
#'
#' @param a #semi-major axis
#' @param b #semi-minor axis
#'
#' @return #circumference of circle/ellipse
#' @export
#'
#' @examples
#' ellipse_perimeter(2) -> 12.566
#' ellipse_perimter(2,12) -> 54.05
#Approximation 1
#ellipse_perimeter = function(a, b=a) {
#  return(2*pi*sqrt((a^2+b^2)/2))
#}
#Approximation 2 -- Ramanujan
ellipse_perimeter = function(a, b=a) {
  inside_func = 3(a+b)- sqrt((3*a+b)(a+3*b))
  
  return( pi*inside_func)
}
