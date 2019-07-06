using LinearAlgebraicRepresentation
Lar = LinearAlgebraicRepresentation
using QHull, LinearAlgebra
using ViewerGL
GL = ViewerGL

const M44 = convert(GL.Matrix4, Matrix{Float64}(I,4,4))

"""
	GLHull(points::Array{Float64,2})::GL.GLMesh

To generate the `GL.mesh` of the ``convex hull`` of an array of `points`.
# Example
```
points = rand(50,3)
GL.VIEW([
      GLHull(points)
      GL.GLAxis(GL.Point3d(0,0,0),GL.Point3d(1,1,1))
])
```
"""
function GLHull(points::Array{Float64,2},color=COLORS[1])::GL.GLMesh
	#data preparation
	ch = QHull.chull(points)
	verts = ch.vertices
	vdict = Dict(zip(verts, 1:length(verts)))
	trias = [[vdict[u],vdict[v],vdict[w]] for (u,v,w) in ch.simplices]
	points = points[verts,:]
	# mesh building
	vertices,normals = GL.lar4mesh(points,trias)
	colors=Vector{Float32}()
	for k=1:length(vertices) append!(colors,color) end

	ret=GL.GLMesh(GL.GL_TRIANGLES)
	ret.vertices = GL.GLVertexBuffer(vertices)
	ret.normals  = GL.GLVertexBuffer(normals)
	ret.colors  = GL.GLVertexBuffer(colors)
	return ret
end


"""
	GLHull2d(points::Array{Float64,2})::GL.GLMesh

To generate the `GL.mesh` of the 1D polygonal ``convex hull`` of an array of 2D `points`.
# Example

```
points = rand(50,2)
GL.VIEW([
	  GL.GLHull2d(points)
	  GL.GLAxis(GL.Point3d(0,0,0),GL.Point3d(1,1,1))
])
```
"""
function GLHull2d(points::Array{Float64,2})::GL.GLMesh # points by row

	ch = QHull.chull(points)
	verts = ch.vertices
	vdict = Dict(zip(verts, 1:length(verts)))
	edges = [[vdict[u],vdict[v]] for (u,v) in ch.simplices]
	points = points[verts,:]
	faces = edges

	vertices=Vector{Float32}()
	normals =Vector{Float32}()
	for face in faces
		p2,p1=points[face[1],:],points[face[2],:]
		t=p2-p1;  n=LinearAlgebra.normalize([-t[2];+t[1]])

		p1 = convert(GL.Point3d, [p1; 0.0])
		p2 = convert(GL.Point3d, [p2; 0.0])
		n  = convert(GL.Point3d, [ n; 0.0])

		append!(vertices,p1); append!(normals,n)
		append!(vertices,p2); append!(normals,n)
	end

	ret=GL.GLMesh(GL.GL_LINES)
	ret.vertices = GL.GLVertexBuffer(vertices)
	ret.normals  = GL.GLVertexBuffer(normals)
	return ret
end

function circularsort(center, points)
@show center
@show points
if size(center,2)==2 center=[center zeros(size(center,1),1)] end
if size(points,2)==2 points=[points zeros(size(points,1),1)] end
	V = points .- center
	v1 = @view V[1,:]; v2 = @view V[2,:];
@show v1
@show v2
	v3 = LinearAlgebra.normalize(LinearAlgebra.cross(v1,v2))
	basis = [normalize(v1) normalize(v2) v3]
	vecs2 = (V * basis)[:,1:2]

	theangle(k) = atan(vecs2[k,2], vecs2[k,1])
	pairs = [[theangle(k), k] for k=1:size(vecs2,1)]
	ordidx = [Int(index) for (alpha,index) in sort(pairs)]
	push!(ordidx, ordidx[1])
	edges = [[ordidx[k],ordidx[k+1]] for k=1:length(ordidx)-1]
	return edges
end


"""
	GLHulls(V::Array{Float64,2},FV::Array{Array{Int64,1},1})::GL.GLMesh

To generate the `GL.mesh` of triangles generated by 2D/3D `points`.
# Example

```
points = rand(50,2)
GL.VIEW([
	  GL.GLHull2d(points)
	  GL.GLAxis(GL.Point3d(0,0,0),GL.Point3d(1,1,1))
])
```
"""
function GLHulls(V::Array{Float64,2},
	FV::Array{Array{Int64,1},1}, back::GL.Point4d=COLORS[1])::GL.GLMesh

	vertices=Vector{Float32}()
	normals =Vector{Float32}()
	colors =Vector{Float32}()
	Rn = size(V,1)

	for face in FV
		points = convert(Lar.Points, V[:,face]')
		center = sum(points,dims=1)/size(points,1)
		edges = circularsort(center, points)

		for (v1,v2) in edges
			p2,p1 = points[v2,:], points[v1,:]

			p1 = convert(GL.Point3d, Rn==2 ? [p1; 0.0] : p1)
			p2 = convert(GL.Point3d, Rn==2 ? [p2; 0.0] : p2)
			p3 = convert(GL.Point3d, Rn==2 ? [center 0.0] : center)
			n=GL.computeNormal(p1,p2,p3)

			append!(vertices,p1); append!(normals,n); append!(colors,back)
			append!(vertices,p2); append!(normals,n); append!(colors,back)
			append!(vertices,p3); append!(normals,n); append!(colors,back)
		end
	end
	ret=GL.GLMesh(GL.GL_TRIANGLES)
	ret.vertices = GL.GLVertexBuffer(vertices)
	ret.normals  = GL.GLVertexBuffer(normals)
	ret.colors  = GL.GLVertexBuffer(colors)
	return ret
end



"""
      GLPolygon(V::Lar.Points,EV::Lar.ChainOp,FE::Lar.ChainOp)::GL.GLMesh

Generate the `GL.GLMesh` ``mesh`` to visualize a ``2D polygon``.

The input polygon is very general, according to the ``Lar`` scheme: it may be non-connected, and may contain multiple holes, i.e. may be non-contractible.

# Example

```
V = hcat([[0,0],[1,0],[1,1],[0,1],[.25,.25],[.75,.25],[.75,.75],[.25,.75]]...)
EV = [[1,2],[2,3],[3,4],[4,1],[5,6],[6,7],[7,8],[8,5]]
```
"""
function GLPolygon(V::Lar.Points,copEV::Lar.ChainOp,copFE::Lar.ChainOp)::GL.GLMesh
      # triangulation
      W = convert(Lar.Points, V')
      EV = Lar.cop2lar(copEV)
      trias = Lar.triangulate2d(W,EV)
      # mesh building
      vertices,normals = GL.lar4mesh(V,trias)
      ret=GL.GLMesh(GL.GL_TRIANGLES)
      ret.vertices = GL.GLVertexBuffer(vertices)
      ret.normals  = GL.GLVertexBuffer(normals)
      return ret
end

"""
      GLPolygon(V::Lar.Points,EV::Lar.Cells)::GL.GLMesh

Generate the `GL.GLMesh` ``mesh`` to visualize a ``2D polygon``.

The input polygon is very general, according to the ``Lar`` scheme: it may be non-connected, and may contain multiple holes, i.e. may be non-contractible.

# Example

```
V = hcat([[0,0],[1,0],[1,1],[0,1],[.25,.25],[.75,.25],[.75,.75],[.25,.75]]...)
EV = [[1,2],[2,3],[3,4],[4,1],[5,6],[6,7],[7,8],[8,5]]

GL.VIEW([
      GL.GLPolygon(V,EV)
      GL.GLAxis(GL.Point3d(0,0,0),GL.Point3d(1,1,1))
])
```
"""
function GLPolygon(V::Lar.Points,EV::Lar.Cells)::GL.GLMesh
      W = convert(Lar.Points, V')
      cop_EV = Lar.coboundary_0(EV::Lar.Cells)
      cop_EW = convert(Lar.ChainOp, cop_EV)
      V, copEV, copFE = Lar.Arrangement.planar_arrangement(
            W::Lar.Points, cop_EW::Lar.ChainOp)
	  if size(V,2)==2
		  V = GL.two2three(V)
	  elseif size(V,2)==3
		  V=V
	  else error("bad coordinates: $V =")
	  end
      return GLPolygon(V, copEV, copFE)
end



"""
	GLLar2gl(V::Array{Float64,2}, CV::Array{Array{Int64,1},1})

Generate the `GL.GLMesh` ``mesh`` to visualize a ``Lar.LAR`` model.

# Example
```
V,CV = Lar.cuboidGrid([10,20,1])
GL.VIEW([
      GL.GLLar2gl(V,CV)
      GL.GLAxis(GL.Point3d(0,0,0),GL.Point3d(1,1,1))
])
```
"""
function GLLar2gl(V::Lar.Points, CV::Lar.Cells)::GL.GLMesh
	points = convert(Array{Float64,2},V') # points by rows
	vertices=Vector{Float32}()
	normals =Vector{Float32}()

	dim = size(points,2)

	for cell in CV
		ch = QHull.chull(points[cell,:])
		verts = ch.vertices
		trias = ch.simplices
		vdict = Dict(zip(verts, 1:length(verts)))
		fdict = Dict(zip(1:length(cell), cell))
		faces = [[vdict[u],vdict[v],vdict[w]] for (u,v,w) in trias]
		triangles = [[fdict[v1],fdict[v2],fdict[v3]] for (v1,v2,v3) in faces]

		cellverts,cellnorms = GL.lar4mesh(points,triangles)
		append!(vertices,cellverts)
		append!(normals,cellnorms)
	end

	ret=GL.GLMesh(GL.GL_TRIANGLES)
	ret.vertices = GL.GLVertexBuffer(vertices)
	ret.normals  = GL.GLVertexBuffer(normals)
	return ret
end

"""
	GLLines(points::Lar.Points,lines::Lar.Cells,color=COLORS[12])::GLMesh
# Example
```
julia> (points, lines) = GL.text("PLaSM");

julia> mesh = GL.GLLines(points::Lar.Points,lines::Lar.Cells);

julia> mesh
```
"""
function GLLines(points::Lar.Points,lines::Lar.Cells,color=COLORS[12])::GL.GLMesh
      points = convert(Lar.Points, points')
      vertices=Vector{Float32}()
	  colors  = Vector{Float32}()
      #normals =Vector{Float32}()
	  if size(points,2) == 2
		  points = [points zeros(size(points,1),1)]
	  end
      for line in lines
            p2,p1 = points[line[1],:], points[line[2],:]
            t=p2-p1;  n=LinearAlgebra.normalize([-t[2];+t[1];t[3]])

            p1 = convert(GL.Point3d, p1)
            p2 = convert(GL.Point3d, p2)
            n  = convert(GL.Point3d,  n)

            append!(vertices,p1); append!(colors,color)
            append!(vertices,p2); append!(colors,color)
      end
      ret=GL.GLMesh(GL.GL_LINES)
      ret.vertices = GL.GLVertexBuffer(vertices)
      ret.colors  = GL.GLVertexBuffer(colors)
      return ret
end



"""
	GLPoints(points::Lar.Points,color=COLORS[12])::GL.GLMesh

Transform an array of points into a mesh of points.
# Example
```
julia> points = rand(50,3)

julia> GL.GLPoints(points::Lar.Points)::GL.GLMesh
ViewerGL.GLMesh(0, [1.0 0.0 0.0 0.0; 0.0 1.0 0.0 0.0; 0.0 0.0 1.0 0.0; 0.0 0.0 0.0 1.0], ViewerGL.GLVertexArray(-1), ViewerGL.GLVertexBuffer(-1, Float32[0.469546, 0.117036, 0.70094, 0.645718, 0.453858, 0.750581, 0.220592, 0.19583, 0.192406, 0.860808  …  0.956595, 0.395031, 0.805344, 0.111219, 0.0562529, 0.923611, 0.634622, 0.794003, 0.0861098, 0.600665]), ViewerGL.GLVertexBuffer(-1, Float32[]), ViewerGL.GLVertexBuffer(-1, Float32[]))
```
"""
function GLPoints(points::Lar.Points,color=COLORS[12])::GL.GLMesh # points by row
      #points = convert(Lar.Points, points')
	  if size(points,2) == 2
		  points = [points zeros(size(points,1),1)]
	  end
      vertices=Vector{Float32}()
      colors =Vector{Float32}()
      for k=1:size(points,1)
		point = convert(GL.Point3d,points[k,:])
        append!(vertices,convert(GL.Point3d,point)); append!(colors,color)
      end
      ret=GL.GLMesh(GL.GL_POINTS)
      ret.vertices = GL.GLVertexBuffer(vertices)
      ret.colors  = GL.GLVertexBuffer(colors)
      return ret
end



"""
	GLPolyhedron(V::Lar.Points, FV::Lar.Cells, T::GL.Matrix4=M44)::GL.GLMesh

Transform a Lar model of a 3D polyhedron, given as a couple (V,FV), into a ModernGL mesh.
# Example
```
julia> V,(VV,EV,FV,CV) = Lar.cuboid([1,1,1],true);

julia> mesh = GL.GLPolyhedron(V::Lar.Points, FV::Lar.Cells);

julia> mesh
```
"""
function GLPolyhedron(V::Lar.Points, FV::Lar.Cells, T::GL.Matrix4=M44)::GL.GLMesh
	# data preparation
	function mycat(a::Lar.Cells)
		out=[]
		for cell in a append!(out,cell) end
		return out
	end
	vindexes = sort(collect(Set(mycat(FV))))
	W = V[:,vindexes]
	vdict = Dict(zip(vindexes,1:length(vindexes)))
	triangles = [[vdict[u],vdict[v],vdict[w]] for (u,v,w) in FV]
	points = (M44 * [W; ones(1,size(W,2))])[1:3,:]
	points = convert(Lar.Points, points') # points by row

	# mesh building
        vertices,normals = GL.lar4mesh(points,triangles)
        ret=GL.GLMesh(GL.GL_TRIANGLES)
        ret.vertices = GL.GLVertexBuffer(vertices)
        ret.normals  = GL.GLVertexBuffer(normals)
        return ret
end



"""
	GLPol(V::Lar.Points, CV::Lar.Cells,color=GL.COLORS[1],alpha=1.0)::GL.GLMesh

Create the GLMesh for a cellular complex with general convex 3-cells.

Mirror the behavior of MKPOL primitive of PLaSM language:
Convert the convex hull of each cell in a set of triangles.
"""
function GLPol(V::Lar.Points, CV::Lar.Cells,color=COLORS[1],alpha=1.0)::GL.GLMesh
	trias,triangles = [],[]
	vcount = 0;
	outpoints = Array{Float64,2}(undef,0,3)
	#data preparation
	color *= alpha
	for cell in CV
		if length(cell)>=3
			points = convert(Lar.Points, V[:,cell]')
			ch = QHull.chull(points)
			trias = ch.simplices
			m = size(ch.points,1)
			trias = [triangle .+ vcount for triangle in ch.simplices]
			append!(triangles,trias)
			outpoints = [outpoints; ch.points]
			vcount += m
		elseif length(cell)==2
			points = convert(Lar.Points, V[:,cell]')
			line = [1,2]
			m = 2
			lines = [line .+ vcount]
			append!(triangles,lines)
			outpoints = [outpoints; points]
			vcount += m
		end
	end
	# mesh building
	FW = convert(Lar.Cells,triangles)
	W = convert(Lar.Points,outpoints')
	mesh = GL.GLGrid(W,FW,color);

	# colors = Vector{Point4d}()
	# c = color
	# for triangle in triangles
	# 	append!(colors,c); append!(colors,c); append!(colors,c)
	# end
	# mesh.colors  = GL.GLVertexBuffer(colors)
end

# mesh = GL.GLPol(V,CV, GL.Point4d(1,1,1,0.2))
# GL.VIEW([ mesh ]);


"""
	GLGrid(V::Lar.Points,CV::Lar.Cells,color=GL.COLORS[1])::GL.GLMesh

A grid is defined here as a cellular `p`-complex where all `p`-cells have the same arity, i.e. the same length as lists of vertices. E.g. are ``grids`` the sequences of points, lines, triangles, quads, `p`-cuboids.
```

```
"""
function GLGrid(V::Lar.Points,CV::Lar.Cells,c=GL.COLORS[1],alpha=0.2::Float64)::GL.GLMesh
	# test if all cells have same length
	ls = map(length,CV)
#	@assert( (&)(map((==)(ls[1]),ls)...) == true )

	n = size(V,1)  # space dimension
	points = GL.embed(3-n)((V,CV))[1]
	cells = CV
	len = length(cells[1])  # cell dimension

	color = c
	color[4] = alpha
	c = Point4d(color)

	vertices= Vector{Float32}()
	normals = Vector{Float32}()
	colors  = Vector{Float32}()

      if len==1   # zero-dimensional grids
		ret=GL.GLMesh(GL.GL_POINTS)
		for k=1:size(points,2)
			p1 = convert(GL.Point3d, points[:,k])
			append!(vertices,p1); #append!(normals,n)
			append!(colors,c); #append!(normals,n)
		end
      elseif len==2   # one-dimensional grids
		ret=GL.GLMesh(GL.GL_LINES)
		for k=1:length(cells)
			p1,p2=cells[k]
			p1 = convert(GL.Point3d, points[:,p1]);
			p2 = convert(GL.Point3d, points[:,p2])
			t = p2-p1;
			n = LinearAlgebra.normalize([-t[2];+t[1];t[3]])
			#n  = convert(GL.Point3d, n)
			append!(vertices,p1); append!(vertices,p2);
			append!(normals,n);   append!(normals,n);
			append!(colors,c);    append!(colors,c);
		end
      elseif len==3 # triangle grids
		vertices=Vector{Float32}()
		normals =Vector{Float32}()
		colors =Vector{Float32}()
		ret=GL.GLMesh(GL.GL_TRIANGLES)
		for k=1:length(cells)
			p1,p2,p3=cells[k]
			p1 = convert(GL.Point3d, points[:,p1]);
			p2 = convert(GL.Point3d, points[:,p2])
			p3 = convert(GL.Point3d, points[:,p3])
			n = GL.computeNormal(p1,p2,p3)
			append!(vertices,p1); append!(vertices,p2); append!(vertices,p3);
			append!(normals,n);   append!(normals,n);   append!(normals,n);
			append!(colors,c);    append!(colors,c);    append!(colors,c);
		end
      elseif len==4  # quad grids
		vertices=Vector{Float32}()
		normals =Vector{Float32}()
		colors =Vector{Float32}()
		ret=GL.GLMesh(GL.GL_QUADS)
		for k=1:length(cells)
			p1,p2,p3,p4=cells[k]
			p1 = convert(GL.Point3d, points[:,p1]);
			p2 = convert(GL.Point3d, points[:,p2])
			p3 = convert(GL.Point3d, points[:,p3])
			p4 = convert(GL.Point3d, points[:,p4])
			n = 0.5*GL.computeNormal(p1,p2,p3)
			append!(vertices,p1); append!(vertices,p2); append!(vertices,p4); append!(vertices,p3);
			append!(normals,n);   append!(normals,n);   append!(normals,n);   append!(normals,n);
			append!(colors,c);    append!(colors,c);    append!(colors,c);    append!(colors,c);
		end
      else # dim > 3
            error("cannot visualize dim > 3")
      end
      ret.vertices = GL.GLVertexBuffer(vertices)
	  ret.normals  = GL.GLVertexBuffer(normals)
	  ret.colors  = GL.GLVertexBuffer(colors)
      return ret
end



# ////////////////////////////////////////////////////////////
"""
	GLExplode(V,FVs,sx=1.2,sy=1.2,sz=1.2,colors=1,alpha=0.2::Float64)

"""
function GLExplode(V,FVs,sx=1.2,sy=1.2,sz=1.2,colors=1,alpha=0.2::Float64)
	assembly = GL.explodecells(V,FVs,sx,sy,sz)
	meshes = Any[]
	for k=0:length(assembly)-1
		# Lar model with constant lemgth of cells, i.e a GRID object !!
		V,FV = assembly[k]
		col = GL.Point4d(1,1,1,1)
		# cyclic color + random color components
		if colors == 1
			col = GL.COLORS[1]
		elseif 2 <= colors <= 12
			col = GL.COLORS[colors]
		else # colors > 12: cyclic colors w random component
			col = GL.COLORS[k%12+1] - (rand(Float64,4)*0.1)
		end
		#col *= alpha
		push!(meshes, GL.GLGrid(V,FV,col,alpha) )
	end
	return meshes
end
