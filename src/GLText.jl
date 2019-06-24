using DataStructures
using LinearAlgebraicRepresentation
Lar = LinearAlgebraicRepresentation
import Base.cat
using ViewerGL
GL = ViewerGL

# Graphic text font implementation
# Vector definition of printable ASCII codes as 1D LAR models.
# Font design from [Geometric Programming for Computer-Aided Design](https://www.amazon.com/Geometric-Programming-Computer-Aided-Design/dp/0471899429?_encoding=UTF8&%2AVersion%2A=1&%2Aentries%2A=0), Wiley, 2003.
"""
	hpcs::Array


"""
hpcs = Tuple{Array{Float64,N} where N,Array{Array{Int64,1},1}}[([0.0, 0.0], [[1]]), ([1.75 1.75 2.0 2.0 1.5 1.5; 1.75 5.5 0.5 1.0 1.0 0.5], [[1, 2], [3, 4], [4, 5], [5, 6], [6, 3]]), ([1.0 2.0 2.0 2.0 1.5 1.5 2.0 3.0 3.0 3.0 2.5 2.5; 4.0 5.0 5.5 6.0 6.0 5.5 4.0 5.0 5.5 6.0 6.0 5.5], [[1, 2], [2, 3], [3, 4], [4, 5], [5, 6], [6, 3], [7, 8], [8, 9], [9, 10], [10, 11], [11, 12], [12, 9]]), ([1.0 3.0 1.0 3.0 1.25 1.75 2.25 2.75; 2.5 2.5 3.5 3.5 1.75 4.0 1.75 4.0], [[1, 2], [3, 4], [5, 6], [7, 8]]), ([0.0 1.0 3.0 4.0 4.0 3.0 1.0 0.0 0.0 1.0 3.0 4.0 2.0 2.0; 1.0 0.0 0.0 1.0 2.0 3.0 3.0 4.0 5.0 6.0 6.0 5.0 -0.5 6.5], [[1, 2], [2, 3], [3, 4], [4, 5], [5, 6], [6, 7], [7, 8], [8, 9], [9, 10], [10, 11], [11, 12], [13, 14]]), ([2.5 2.5 2.0 2.0 2.5 2.5 2.0 2.0 1.5 3.5; 0.0 0.5 0.5 0.0 5.5 6.0 6.0 5.5 5.5 11.5], [[1, 2], [2, 3], [3, 4], [4, 1], [5, 6], [6, 7], [7, 8], [8, 5], [9, 10]]), ([4.0 3.0 1.0 0.0 0.0 1.0 2.0 3.0 3.0 2.0 1.0 1.0 3.0 4.0; 1.0 0.0 0.0 1.0 2.0 3.0 3.0 4.0 5.0 6.0 5.0 4.0 2.0 2.0], [[1, 2], [2, 3], [3, 4], [4, 5], [5, 6], [6, 7], [7, 8], [8, 9], [9, 10], [10, 11], [11, 12], [12, 13], [13, 14]]), ([1.0 2.0 2.0 2.0 1.5 1.5; 4.0 5.0 5.5 6.0 6.0 5.5], [[1, 2], [2, 3], [3, 4], [4, 5], [5, 6], [6, 3]]), ([2.0 1.0 0.5 1.0 2.0; 0.0 1.0 3.0 5.0 6.0], [[1, 2], [2, 3], [3, 4], [4, 5]]), ([2.0 3.0 3.5 3.0 2.0; 0.0 1.0 3.0 5.0 6.0], [[1, 2], [2, 3], [3, 4], [4, 5]]), ([1.0 3.0 2.0 2.0 1.0 3.0 1.0 3.0; 3.0 3.0 2.0 4.0 2.0 4.0 4.0 2.0], [[1, 2], [3, 4], [5, 6], [7, 8]]), ([1.0 3.0 2.0 2.0; 3.0 3.0 2.0 4.0], [[1, 2], [3, 4]]), ([1.0 2.0 2.0 2.0 1.5 1.5; -1.0 0.0 0.5 1.0 1.0 0.5], [[1, 2], [2, 3], [3, 4], [4, 5], [5, 6], [6, 3]]), ([1.0 3.0; 3.0 3.0], [[1, 2]]), ([2.0 2.0 1.5 1.5 2.0; 0.0 0.5 0.5 0.0 0.0], [[1, 2], [2, 3], [3, 4], [4, 5]]), ([1.0 3.0; 0.0 6.0], [[1, 2]]), ([4.0 3.0 1.0 0.0 0.0 1.0 3.0 4.0; 1.0 0.0 0.0 1.0 5.0 6.0 6.0 5.0], [[1, 2], [2, 3], [3, 4], [4, 5], [5, 6], [6, 7], [7, 8], [8, 1], [4, 8]]), ([0.0 2.0 2.0 0.0 4.0; 4.0 6.0 0.0 0.0 0.0], [[1, 2], [2, 3], [4, 5]]), ([0.0 0.0 1.0 3.0 4.0 4.0 0.0 4.0; 4.0 5.0 6.0 6.0 5.0 4.0 0.0 0.0], [[1, 2], [2, 3], [3, 4], [4, 5], [5, 6], [6, 7], [7, 8]]), ([0.0 4.0 2.0 4.0 4.0 3.0 1.0 0.0 0.0; 6.0 6.0 4.0 2.0 1.0 0.0 0.0 1.0 2.0], [[1, 2], [2, 3], [3, 4], [4, 5], [5, 6], [6, 7], [7, 8], [8, 9]]), ([4.0 0.0 4.0 4.0; 1.0 1.0 6.0 0.0], [[1, 2], [2, 3], [3, 4]]), ([4.0 0.0 0.0 3.0 4.0 4.0 3.0 1.0 0.0 0.0; 6.0 6.0 4.0 4.0 3.0 1.0 0.0 0.0 1.0 2.0], [[1, 2], [2, 3], [3, 4], [4, 5], [5, 6], [6, 7], [7, 8], [8, 9], [9, 10]]), ([4.0 1.0 0.0 0.0 1.0 3.0 4.0 4.0 3.0 1.0 0.0; 6.0 6.0 5.0 1.0 0.0 0.0 1.0 3.0 4.0 4.0 3.0], [[1, 2], [2, 3], [3, 4], [4, 5], [5, 6], [6, 7], [7, 8], [8, 9], [9, 10], [10, 11]]), ([0.0 0.0 4.0 0.0; 5.0 6.0 6.0 0.0], [[1, 2], [2, 3], [3, 4]]), ([1.0 3.0 4.0 4.0 3.0 1.0 0.0 0.0 4.0 4.0 3.0 1.0 0.0 0.0; 0.0 0.0 1.0 2.0 3.0 3.0 2.0 1.0 4.0 5.0 6.0 6.0 5.0 4.0], [[1, 2], [2, 3], [3, 4], [4, 5], [5, 6], [6, 7], [7, 8], [8, 1], [6, 5], [5, 9], [9, 10], [10, 11], [11, 12], [12, 13], [13, 14], [14, 6]]), ([0.0 3.0 4.0 4.0 3.0 1.0 0.0 0.0 1.0 3.0 4.0; 0.0 0.0 1.0 5.0 6.0 6.0 5.0 3.0 2.0 2.0 3.0], [[1, 2], [2, 3], [3, 4], [4, 5], [5, 6], [6, 7], [7, 8], [8, 9], [9, 10], [10, 11]]), ([2.0 2.0 1.5 1.5 2.0 2.0 1.5 1.5; 1.0 1.5 1.5 1.0 3.0 3.5 3.5 3.0], [[1, 2], [2, 3], [3, 4], [4, 1], [5, 6], [6, 7], [7, 8], [8, 5]]), ([2.0 2.0 1.5 1.5 1.0 2.0 2.0 2.0 1.5 1.5; 3.0 3.5 3.5 3.0 -0.5 0.5 1.0 1.5 1.5 1.0], [[1, 2], [2, 3], [3, 4], [4, 1], [5, 6], [6, 7], [7, 8], [8, 9], [9, 10], [10, 7]]), ([3.0 0.0 3.0; 6.0 3.0 0.0], [[1, 2], [2, 3]]), ([1.0 3.0 1.0 3.0; 2.5 2.5 3.5 3.5], [[1, 2], [3, 4]]), ([1.0 4.0 1.0; 6.0 3.0 0.0], [[1, 2], [2, 3]]), ([2.0 2.0 1.5 1.5 1.75 1.75 3.0 3.0 2.0 1.0 0.0 0.0; 0.0 0.5 0.5 0.0 1.0 2.75 4.0 5.0 6.0 6.0 5.0 4.0], [[1, 2], [2, 3], [3, 4], [4, 1], [5, 6], [6, 7], [7, 8], [8, 9], [9, 10], [10, 11], [11, 12]]), ([4.0 1.0 0.0 0.0 1.0 3.0 4.0 4.0 2.0 1.0 2.0 3.0 2.0; 0.0 0.0 1.0 3.0 4.0 4.0 3.0 1.0 1.0 2.0 3.0 2.0 1.0], [[1, 2], [2, 3], [3, 4], [4, 5], [5, 6], [6, 7], [7, 8], [8, 9], [9, 10], [10, 11], [11, 12], [12, 13]]), ([0.0 0.0 1.0 3.0 4.0 4.0 0.0 4.0; 0.0 5.0 6.0 6.0 5.0 0.0 2.0 2.0], [[1, 2], [2, 3], [3, 4], [4, 5], [5, 6], [7, 8]]), ([0.0 0.0 3.0 4.0 4.0 3.0 4.0 4.0 3.0 0.0 0.0 3.0; 0.0 6.0 6.0 5.0 4.0 3.0 2.0 1.0 0.0 0.0 3.0 3.0], [[1, 2], [2, 3], [3, 4], [4, 5], [5, 6], [6, 7], [7, 8], [8, 9], [9, 10], [11, 12]]), ([4.0 3.0 1.0 0.0 0.0 1.0 3.0 4.0; 1.0 0.0 0.0 1.0 5.0 6.0 6.0 5.0], [[1, 2], [2, 3], [3, 4], [4, 5], [5, 6], [6, 7], [7, 8]]), ([0.0 0.0 3.0 4.0 4.0 3.0 0.0; 0.0 6.0 6.0 5.0 1.0 0.0 0.0], [[1, 2], [2, 3], [3, 4], [4, 5], [5, 6], [6, 7]]), ([4.0 0.0 0.0 4.0 0.0 3.0; 0.0 0.0 6.0 6.0 3.0 3.0], [[1, 2], [2, 3], [3, 4], [5, 6]]), ([0.0 0.0 4.0 0.0 3.0; 0.0 6.0 6.0 3.0 3.0], [[1, 2], [2, 3], [4, 5]]), ([2.0 4.0 4.0 3.0 1.0 0.0 0.0 1.0 3.0 4.0; 3.0 3.0 1.0 0.0 0.0 1.0 5.0 6.0 6.0 5.0], [[1, 2], [2, 3], [3, 4], [4, 5], [5, 6], [6, 7], [7, 8], [8, 9], [9, 10]]), ([0.0 0.0 4.0 4.0 0.0 4.0; 0.0 6.0 6.0 0.0 3.0 3.0], [[1, 2], [3, 4], [5, 6]]), ([2.0 2.0 1.0 3.0 1.0 3.0; 0.0 6.0 0.0 0.0 6.0 6.0], [[1, 2], [3, 4], [5, 6]]), ([0.0 1.0 2.0 3.0 3.0 2.0 4.0; 1.0 0.0 0.0 1.0 6.0 6.0 6.0], [[1, 2], [2, 3], [3, 4], [4, 5], [6, 7]]), ([4.0 0.0 4.0 0.0 0.0; 6.0 3.0 0.0 0.0 6.0], [[1, 2], [2, 3], [4, 5]]), ([4.0 0.0 0.0; 0.0 0.0 6.0], [[1, 2], [2, 3]]), ([0.0 0.0 2.0 4.0 4.0; 0.0 6.0 4.0 6.0 0.0], [[1, 2], [2, 3], [3, 4], [4, 5]]), ([0.0 0.0 4.0 4.0 4.0; 0.0 6.0 2.0 0.0 6.0], [[1, 2], [2, 3], [4, 5]]), ([4.0 3.0 1.0 0.0 0.0 1.0 3.0 4.0 4.0; 1.0 0.0 0.0 1.0 5.0 6.0 6.0 5.0 1.0], [[1, 2], [2, 3], [3, 4], [4, 5], [5, 6], [6, 7], [7, 8], [8, 9]]), ([0.0 0.0 3.0 4.0 4.0 3.0 0.0; 0.0 6.0 6.0 5.0 3.0 2.0 2.0], [[1, 2], [2, 3], [3, 4], [4, 5], [5, 6], [6, 7]]), ([4.0 3.0 1.0 0.0 0.0 1.0 3.0 4.0 4.0 3.0 4.0; 1.0 0.0 0.0 1.0 5.0 6.0 6.0 5.0 1.0 1.0 0.0], [[1, 2], [2, 3], [3, 4], [4, 5], [5, 6], [6, 7], [7, 8], [8, 9], [10, 11]]), ([0.0 0.0 3.0 4.0 4.0 3.0 0.0 3.0 4.0; 0.0 6.0 6.0 5.0 3.0 2.0 2.0 2.0 0.0], [[1, 2], [2, 3], [3, 4], [4, 5], [5, 6], [6, 7], [8, 9]]), ([0.0 1.0 3.0 4.0 4.0 3.0 1.0 0.0 0.0 1.0 3.0 4.0; 1.0 0.0 0.0 1.0 2.0 3.0 3.0 4.0 5.0 6.0 6.0 5.0], [[1, 2], [2, 3], [3, 4], [4, 5], [5, 6], [6, 7], [7, 8], [8, 9], [9, 10], [10, 11], [11, 12]]), ([2.0 2.0 0.0 4.0; 0.0 6.0 6.0 6.0], [[1, 2], [3, 4]]), ([0.0 0.0 1.0 3.0 4.0 4.0; 6.0 1.0 0.0 0.0 1.0 6.0], [[1, 2], [2, 3], [3, 4], [4, 5], [5, 6]]), ([0.0 2.0 4.0; 6.0 0.0 6.0], [[1, 2], [2, 3]]), ([0.0 0.0 1.0 2.0 3.0 4.0 4.0; 6.0 3.0 0.0 3.0 0.0 3.0 6.0], [[1, 2], [2, 3], [3, 4], [4, 5], [5, 6], [6, 7]]), ([0.0 4.0 0.0 4.0; 0.0 6.0 6.0 0.0], [[1, 2], [3, 4]]), ([0.0 2.0 4.0 2.0 2.0; 6.0 2.0 6.0 2.0 0.0], [[1, 2], [2, 3], [4, 5]]), ([0.0 4.0 0.0 4.0; 6.0 6.0 0.0 0.0], [[1, 2], [2, 3], [3, 4]]), ([2.0 1.0 1.0 2.0; 0.0 0.0 6.0 6.0], [[1, 2], [2, 3], [3, 4]]), ([1.0 3.0; 6.0 0.0], [[1, 2]]), ([2.0 3.0 3.0 2.0; 0.0 0.0 6.0 6.0], [[1, 2], [2, 3], [3, 4]]), ([1.0 2.0 3.0; 5.0 6.0 5.0], [[1, 2], [2, 3]]), ([1.0 4.0; 0.0 0.0], [[1, 2]]), ([2.0 2.0 3.0 2.5 2.5 2.0; 4.5 5.0 6.0 4.0 4.5 4.0], [[1, 2], [2, 3], [4, 5], [5, 1], [1, 6], [6, 4]]), ([4.0 3.0 1.0 0.0 0.0 1.0 3.0 4.0 4.0 4.0; 1.0 0.0 0.0 1.0 2.0 3.0 3.0 2.0 0.0 3.0], [[1, 2], [2, 3], [3, 4], [4, 5], [5, 6], [6, 7], [7, 8], [8, 1], [9, 10]]), ([4.0 3.0 1.0 0.0 0.0 1.0 3.0 4.0 0.0 0.0 1.0; 1.0 0.0 0.0 1.0 2.0 3.0 3.0 2.0 0.0 5.0 5.0], [[1, 2], [2, 3], [3, 4], [4, 5], [5, 6], [6, 7], [7, 8], [8, 1], [9, 10], [10, 11]]), ([4.0 3.0 1.0 0.0 0.0 1.0 3.0 4.0; 1.0 0.0 0.0 1.0 2.0 3.0 3.0 2.0], [[1, 2], [2, 3], [3, 4], [4, 5], [5, 6], [6, 7], [7, 8]]), ([4.0 3.0 1.0 0.0 0.0 1.0 3.0 4.0 4.0 4.0 3.0; 1.0 0.0 0.0 1.0 2.0 3.0 3.0 2.0 0.0 5.0 5.0], [[1, 2], [2, 3], [3, 4], [4, 5], [5, 6], [6, 7], [7, 8], [8, 1], [9, 10], [10, 11]]), ([4.0 1.0 0.0 0.0 1.0 3.0 4.0 4.0 0.0; 0.0 0.0 1.0 2.0 3.0 3.0 2.0 1.0 1.0], [[1, 2], [2, 3], [3, 4], [4, 5], [5, 6], [6, 7], [7, 8], [8, 9]]), ([4.0 4.0 3.0 2.0 1.0 1.0 0.0 2.0; 3.0 4.0 5.0 5.0 4.0 0.0 1.0 1.0], [[1, 2], [2, 3], [3, 4], [4, 5], [5, 6], [7, 8]]), ([4.0 3.0 1.0 0.0 0.0 1.0 3.0 4.0 4.0 3.0 1.0 0.0; 1.0 0.0 0.0 1.0 2.0 3.0 3.0 2.0 0.0 -1.0 -1.0 0.0], [[1, 2], [2, 3], [3, 4], [4, 5], [5, 6], [6, 7], [7, 8], [8, 1], [1, 9], [9, 10], [10, 11], [11, 12]]), ([4.0 4.0 3.0 1.0 0.0 0.0 0.0 1.0; 0.0 2.0 3.0 3.0 2.0 0.0 5.0 5.0], [[1, 2], [2, 3], [3, 4], [4, 5], [6, 7], [7, 8]]), ([1.0 3.0 1.0 3.0 2.0 2.0 2.25 2.25 1.75 1.75; 0.0 0.0 3.0 3.0 0.0 3.0 3.75 4.25 4.25 3.75], [[1, 2], [3, 4], [5, 6], [7, 8], [8, 9], [9, 10], [10, 7]]), ([1.0 3.0 2.0 2.0 1.0 0.0 2.25 2.25 1.75 1.75; 3.0 3.0 3.0 0.0 -1.0 0.0 3.75 4.25 4.25 3.75], [[1, 2], [3, 4], [4, 5], [5, 6], [7, 8], [8, 9], [9, 10], [10, 7]]), ([0.0 1.0 1.0 0.0 4.0 2.0 1.0 3.0 4.0; 0.0 0.0 3.0 3.0 0.0 0.0 1.0 3.0 3.0], [[1, 2], [2, 3], [3, 4], [5, 6], [6, 7], [7, 8], [8, 9]]), ([2.0 2.0 1.0 1.0 3.0; 0.0 5.0 5.0 0.0 0.0], [[1, 2], [2, 3], [4, 5]]), ([4.0 4.0 2.0 2.0 2.0 0.0 0.0 0.0; 0.0 3.0 2.0 0.0 3.0 2.0 0.0 3.0], [[1, 2], [2, 3], [4, 5], [5, 6], [7, 8]]), ([3.0 3.0 1.0 1.0 1.0; 0.0 3.0 2.0 0.0 3.0], [[1, 2], [2, 3], [4, 5]]), ([4.0 3.0 1.0 0.0 0.0 1.0 3.0 4.0 4.0; 1.0 0.0 0.0 1.0 2.0 3.0 3.0 2.0 1.0], [[1, 2], [2, 3], [3, 4], [4, 5], [5, 6], [6, 7], [7, 8], [8, 9]]), ([4.0 3.0 1.0 0.0 0.0 1.0 3.0 4.0 0.0 0.0; 1.0 0.0 0.0 1.0 2.0 3.0 3.0 2.0 3.0 -1.0], [[1, 2], [2, 3], [3, 4], [4, 5], [5, 6], [6, 7], [7, 8], [8, 1], [9, 10]]), ([4.0 3.0 1.0 0.0 0.0 1.0 3.0 4.0 4.0 4.0; 1.0 0.0 0.0 1.0 2.0 3.0 3.0 2.0 3.0 -1.0], [[1, 2], [2, 3], [3, 4], [4, 5], [5, 6], [6, 7], [7, 8], [8, 1], [9, 10]]), ([0.0 2.0 1.0 1.0 1.0 2.0 3.0 4.0; 0.0 0.0 0.0 3.0 2.0 3.0 3.0 2.0], [[1, 2], [3, 4], [5, 6], [6, 7], [7, 8]]), ([0.0 4.0 3.0 1.0 0.0 1.0 3.0 4.0; 0.0 0.0 1.0 1.0 2.0 3.0 3.0 2.0], [[1, 2], [2, 3], [3, 4], [4, 5], [5, 6], [6, 7], [7, 8]]), ([1.0 3.0 2.0 2.0 2.0 3.0; 0.0 0.0 0.0 5.0 4.0 4.0], [[1, 2], [3, 4], [5, 6]]), ([0.0 1.0 1.0 2.0 3.0 4.0 4.0; 3.0 3.0 1.0 0.0 0.0 1.0 3.0], [[1, 2], [2, 3], [3, 4], [4, 5], [5, 6], [6, 7]]), ([0.0 1.0 3.0 4.0; 3.0 0.0 3.0 3.0], [[1, 2], [2, 3], [3, 4]]), ([0.0 0.0 1.0 2.0 3.0 4.0 4.0; 3.0 2.0 0.0 2.0 0.0 2.0 3.0], [[1, 2], [2, 3], [3, 4], [4, 5], [5, 6], [6, 7]]), ([0.0 1.0 4.0 1.0 4.0; 3.0 3.0 0.0 0.0 3.0], [[1, 2], [2, 3], [4, 5]]), ([0.0 1.0 2.5 0.0 1.0 4.0; 3.0 3.0 1.5 0.0 0.0 3.0], [[1, 2], [2, 3], [4, 5], [5, 6]]), ([0.0 0.0 3.0 0.0 3.0 4.0; 2.0 3.0 3.0 0.0 0.0 1.0], [[1, 2], [2, 3], [3, 4], [4, 5], [5, 6]]), ([2.5 2.0 2.0 1.5 2.0 2.0 2.5; 6.5 6.0 3.5 3.0 2.5 0.0 -0.5], [[1, 2], [2, 3], [3, 4], [4, 5], [5, 6], [6, 7]]), ([2.0 2.0; 0.0 5.0], [[1, 2]]), ([1.5 2.0 2.0 2.5 2.0 2.0 1.5; 6.5 6.0 3.5 3.0 2.5 0.0 -0.5], [[1, 2], [2, 3], [3, 4], [4, 5], [5, 6], [6, 7]]), ([1.0 1.75 2.75 3.5; 5.0 5.5 5.0 5.5], [[1, 2], [2, 3], [3, 4]])]


"""
ascii_LAR = DataStructures.OrderedDict{Int,Lar.LAR}()

	GL.ascii2lar::{Int,Lar.LAR}

*Ordered dictionary* of printable ASCII codes as one-dimensional *LAR models* in 2D.

`Key` is the `integer` ASCII code between 32 and 126.
# Example
```
julia> GL.ascii2lar[46]
([2.0 2.0 … 1.5 2.0; 0.0 0.5 … 0.0 0.0], Array{Int64,1}[[1, 2], [2, 3], [3, 4], [4, 5]])

julia> GL.ascii2lar[126]
([1.0 1.75 2.75 3.5; 5.0 5.5 5.0 5.5], Array{Int64,1}[[1, 2], [2, 3], [3, 4]])
```
"""
ascii2lar = DataStructures.OrderedDict(zip(32:126,hpcs))



# Attributes for `text` 2D graphics primitive.
# Reference to GKS ISO Graphics Standard (ISO/IEC 7942-4:1998)

const textalignment = "centre" #default value
const textangle = pi/4 #default value
const textwidth = 1.0 #default value
const textheight = 1.0 #default value
const textspacing = 0.25 #default value
const fontwidth = 4.0 #default value
const fontheight = 8.0 #default value
const fontspacing = 1.0 #default value


"""
	charpols(mystring::String)::Array{LAR,1}

Return the `array` of `LAR` models, for chars in `mystring`.
"""
function charpols(mystring)
    return [ascii2lar[code] for code in [Int(char) for char in mystring]]
end



"""
	charseq(mystring::String)::Array{Char,1}

# Example
```
julia> GL.charseq("PLaSM")
5-element Array{Char,1}:
 'P'
 'L'
 'a'
 'S'
 'M'
```
"""
function charseq(mystring)
	return [char for char in mystring]
end

function cons(funs)
	return x -> [f(x) for f in funs]
end
function comp(funs)
	function compose(f,g)
	  return x -> f(g(x))
	end
	id = x->x
	return reduce(compose, funs; init=id)
end
function distr(args)
	list,element = args
	return [ [e,element] for e in list ]
end

"""
	text(mystring::String)::LAR

Compute the one-dim *LAR model* drawing the contents of `mystring`

# Example
```
julia> model = GL.text("PLaSM")
# output
([0.0 0.0 3.0 4.0 4.0 3.0 0.0 9.0 5.0 5.0 14.0 13.0 11.0 10.0
10.0 11.0 13.0 14.0 14.0 14.0 15.0 16.0 18.0 19.0 19.0 18.0 16.0 15.0 15.0 16.0 18.0
19.0 20.0 20.0 22.0 24.0 24.0; 0.0 6.0 6.0 5.0 3.0 2.0 2.0 0.0 0.0 6.0 1.0 0.0 0.0 1.0
2.0 3.0 3.0 2.0 0.0 3.0 1.0 0.0 0.0 1.0 2.0 3.0 3.0 4.0 5.0 6.0 6.0 5.0 0.0 6.0 4.0
6.0 0.0],
Array{Int64,1}[[1,2],[2,3],[3,4],[4,5],[5,6],[6,7],[8,9],[9,10],[11,12],[12,13],[13,14],
[14,15],[15,16],[16,17],[17,18],[18,11],[19,20],[21,22],[22,23],[23,24],[24,25],[25,26],
[26,27],[27,28],[28,29],[29,30],[30,31],[31,32],[33,34],[34,35],[35,36],[36,37]])

julia> GL.VIEW([GL.GLLar2gl(model...)])
```
"""
function text(mystring,flag=true)
	V,EV = GL.comp([ Lar.struct2lar, Lar.Struct, cat, distr,
			GL.cons([ charpols, k(Lar.t(fontspacing+fontwidth,0)) ]),charseq ])(mystring)
	out = GL.normalize3(V,flag),EV
	return out
end



"""
	a2a(mat::Matrix)(models::Array{LAR,1})::Struct.body

Local function, service to `textWithAttributes` implementation.
"""
function a2a(mat)
	function a2a0(models)
		assembly = []
		for model in models
			push!( assembly, Lar.Struct([ mat,model ]) )
		end
		assembly
	end
	return a2a0
end


"""
	translate(c::Number)(lar::LAR)::LAR

Local function, service to `textWithAttributes` implementation.
"""
function translate(c)
	function translate0(lar)
		xs = lar[1][1,:]
		width = maximum(xs) - minimum(xs)
		Lar.apply(Lar.t(width/c,0))(lar)
	end
	return translate0
end


"""
	align(textalignment="centre"::String)(model::LAR)::LAR

Local function, service to `textWithAttributes` implementation.
"""
function align(textalignment="centre")
	function align1(model)
		if ( textalignment == "centre" ) out=translate(-2)(model)
		elseif ( textalignment == "right" ) out=translate(-1)(model)
		elseif ( textalignment == "left" ) out=model
		end
		return out
	end
end



"""
 	cat(args)

Redefined locally, as service to `textWithAttributes` implementation.
"""
function cat(args)
	return reduce( (x,y) -> append!(x,y), args; init=[] )
end


"""
	k(Any)(x)

*Constant* functional of FL and PLaSM languages.

Gives a constant functional that always returns the actual parameter
when applied to another parameter.

#	Examples

```
julia> GL.k(10)(100)
10

julia> GL.k(sin)(cos)
sin
```
"""
function k(any::Any)
	x->any
end



"""
	apply(fun::Function, params::Array)

"""
function apply(fun::Function)
	function apply0(params::Array)
		return fun(params)
	end
	return apply0
end


"""
	textWithAttributes(textalignment='centre', textangle=0,
		textwidth=1.0, textheight=2.0, textspacing=0.25)(strand::String)::LAR

Partial implementation of the GKS's graphics primitive `text`.

# Example

```
Plasm.view(Plasm.textWithAttributes("left", pi/4)("PLaSM"))
```
"""
# function textWithAttributes(textalignment="centre", textangle=0,
# 							textwidth=1.0, textheight=2.0, textspacing=0.25)
# 	function textWithAttributes0(strand)
# 		id = x->x
# 		mat = Lar.s(textwidth/fontwidth,textheight/fontheight)
# 		Lar.apply(Lar.r(textangle),
# 		comp([ align(textalignment),
# 		   Lar.struct2lar,
# 		   Lar.Struct,
# 		   cat,
# 		   distr,
# 		   GL.cons([ a2a(mat) ∘ charpols,
# 				k(Lar.t(textwidth+textspacing,0)) ]),
# 		   charseq ]))(strand)
# 	end
# 	return textWithAttributes0
# end
# # TODO: fix textWithAttributes


"""
	embed(n::Int)(model::LAR)::LAR

Embed a `LAR` `model` of dimension ``d`` in a space ``R^{d+n}``.
The embedding is done by adding ``d`` zero coordinates to each vertex.

# Example

```
julia> square = Lar.cuboid([1,1])
([0.0 0.0 1.0 1.0; 0.0 1.0 0.0 1.0], Array{Int64,1}[[1, 2, 3, 4]])

julia> GL.embed(1)(square)
([0.0 0.0 1.0 1.0; 0.0 1.0 0.0 1.0; 0.0 0.0 0.0 0.0], Array{Int64,1}[[1, 2, 3, 4]])
```
"""
function embed(n)
	function embed0( larmodel )
		return [larmodel[1]; zeros(n,size(larmodel[1],2))], larmodel[2]
	end
	return embed0
end

#=
"""
	numbering(model::LARmodel)

Display a *wireframe* of `model` cells, of any dimension, with their *ordinal number*.
Different `colors` and size are used for the various dimensional cells.

# Examples

```
model = Lar.cuboidGrid([3,4,2], true)
Plasm.view(Plasm.numbering()(model))

model = Lar.cuboidGrid([10,10], true)
Plasm.view(Plasm.numbering(1.5)(model))
```
"""
function numbering(numberSizeScaling=1)
	p = PyCall.pyimport("pyplasm")
	function numbering0(model)
		V,cells = model
		if size(V,1)==2
			V = GL.embed(1)(model)[1]
		end
		wireframe = Plasm.lar2hpc(V,cells[2])
		ns = numberSizeScaling
		gcode = Plasm.textWithAttributes("centre", 0, 0.1ns, 0.2ns, 0.025ns)
		scene = [wireframe]
		for (h,skel) in enumerate(cells)
			  colors = [p["GREEN"], p["YELLOW"], p["CYAN"], p["ORANGE"]]
		 	  nums = []
			  for (k,cell) in enumerate(skel)
				center = sum([V[:,v] for v in cell])/length(cell)
				code = Plasm.embed(1)( gcode(string(k)) )
				scaling = (0.6+0.1h,0.6+0.1h,1)
				push!(nums, Lar.struct2lar( Lar.Struct([
					Lar.t(center...), Lar.s(scaling...), code ]) ))
			end
			hpc = Plasm.lar2hpc(nums)
			push!( scene, p["COLOR"](colors[h])(hpc) )
		end
		p["STRUCT"]( scene )
	end
	return numbering0
end
=#


"""
#	numbering(scaling=0.1)
#		(V::Lar.Points, copEV::Lar.ChainOp, copFE::Lar.ChainOp)::Lar.Hpc

Produce the numbered `Hpc` of `planar_arrangement()` 2D output.
Vertices in `V` are stored by row.

# Example

```julia
using LinearAlgebraicRepresentation
using Plasm, SparseArrays
Lar = LinearAlgebraicRepresentation

V,EV = Lar.randomcuboids(7, 1.0);
V = GL.normalize(V,flag=true);
W = convert(Lar.Points, V');
cop_EV = Lar.coboundary_0(EV::Lar.Cells);
cop_EW = convert(Lar.ChainOp, cop_EV);
V, copEV, copFE = Lar.planar_arrangement(W, cop_EW);

Plasm.view( Plasm.numbering(0.05)((V, copEV, copFE)) )
```
"""
function numbering1(scaling=0.1)
	function numbering0(model::Tuple{Lar.Points,Lar.ChainOp,Lar.ChainOp})
		(V, copEV, copFE) = model
		VV = [[k] for k=1:size(V,1)]
		EV = [findnz(copEV[h,:])[1] for h=1:size(copEV,1)]
		FV = [collect(Set(cat(EV[e] for e in findnz(copFE[i,:])[1]))) for i=1:size(copFE,1)]
		FV = convert(Array{Array{Int64,1},1}, FV)
		model = (convert(Lar.Points, V'), Lar.Cells[VV,EV,FV])
		return GL.numbering(scaling)(model)
	end
	return numbering0
end