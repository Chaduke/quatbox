pico-8 cartridge // http://www.pico-8.com
version 42
__lua__
-- quatbox
-- a quaternion playground
-- learn the math, then play

-->8
-- boot / state machine

function _init()
 state="menu"
 menu_sel=1
 cur=1
 menuitem(1,"main menu",function()
  state="menu"
 end)
end

function _update()
 if state=="menu" then update_menu()
 elseif state=="learn" then update_learn()
 elseif state=="play" then update_play()
 end
end

function _draw()
 if state=="menu" then draw_menu()
 elseif state=="learn" then draw_learn()
 elseif state=="play" then draw_play()
 end
end

-->8
-- main menu

function update_menu()
 if btnp(2) or btnp(3) then
  menu_sel=menu_sel%2+1
 end
 if btnp(4) then
  if menu_sel==1 then
   cur=1
   state="learn"
   if lessons[cur].init then lessons[cur].init() end
  else
   state="play"
   play_init()
  end
 end
end

function draw_menu()
 cls(0)
 print("quatbox",46,30,7)
 print("a quaternion playground",22,38,6)
 print((menu_sel==1 and ">" or " ").." learn",44,60,
  menu_sel==1 and 11 or 7)
 print((menu_sel==2 and ">" or " ").." play",44,68,
  menu_sel==2 and 11 or 7)
 print("⬆️⬇️ select   ❎ confirm",18,110,5)
end

-->8
-- shared helpers

function fmt(n)
 return flr(n*10+0.5)/10
end

function draw_header(title,instr)
 print(title,1,1,7)
 print(instr,1,8,6)
end

function draw_readout(lines)
 for i=1,#lines do
  print(lines[i],1,96+(i-1)*7,7)
 end
end

function rotx(v,t)
 local s,c=sin(t),cos(t)
 return {x=v.x,y=v.y*c-v.z*s,z=v.y*s+v.z*c}
end

function roty(v,t)
 local s,c=sin(t),cos(t)
 return {x=v.x*c+v.z*s,y=v.y,z=-v.x*s+v.z*c}
end

function rotz(v,t)
 local s,c=sin(t),cos(t)
 return {x=v.x*c-v.y*s,y=v.x*s+v.y*c,z=v.z}
end

function draw_tri(p1,p2,p3,ox,oy,col)
 line(p1.x+ox,p1.y+oy,p2.x+ox,p2.y+oy,col)
 line(p2.x+ox,p2.y+oy,p3.x+ox,p3.y+oy,col)
 line(p3.x+ox,p3.y+oy,p1.x+ox,p1.y+oy,col)
end

-->8
-- learn engine

function update_learn()
 if btnp(4) then
  cur=cur%#lessons+1
  if lessons[cur].init then lessons[cur].init() end
 elseif btnp(5) then
  if cur==1 then
   state="menu"
  else
   cur=cur-1
   if lessons[cur].init then lessons[cur].init() end
  end
 end
 if lessons[cur].update then lessons[cur].update() end
end

function draw_learn()
 cls(0)
 lessons[cur].draw()
 print(cur.."/"..#lessons.."  ❎ next   🅾️ back",1,120,5)
end

-->8
-- act 1: space and the problem

pts3={
 {x=0,y=-30,z=0},
 {x=-26,y=15,z=0},
 {x=26,y=15,z=0}
}

rotfns={rotx,roty,rotz}
axnames={"x","y","z"}

lessons={}

-- 1. points on a plane
lessons[1]={
 init=function()
  l1x,l1y=20,-10
 end,
 update=function()
  if btn(0) then l1x-=1 end
  if btn(1) then l1x+=1 end
  if btn(2) then l1y-=1 end
  if btn(3) then l1y+=1 end
  l1x=mid(-60,l1x,60)
  l1y=mid(-38,l1y,38)
 end,
 draw=function()
  draw_header("1. points on a plane","move the dot with the d-pad")
  local ox,oy=64,54
  line(ox-60,oy,ox+60,oy,5)
  line(ox,oy-38,ox,oy+38,5)
  circfill(ox+l1x,oy+l1y,2,11)
  draw_readout({"x: "..l1x,"y: "..l1y})
 end
}

-- 2. points in 3d
lessons[2]={
 init=function()
  l2x,l2z=10,0
 end,
 update=function()
  if btn(0) then l2x-=1 end
  if btn(1) then l2x+=1 end
  if btn(2) then l2z-=1 end
  if btn(3) then l2z+=1 end
  l2x=mid(-25,l2x,25)
  l2z=mid(-25,l2z,25)
 end,
 draw=function()
  draw_header("2. points in 3d","⬅️➡️ x   ⬆️⬇️ z (depth)")
  local fx,fy=32,58
  print("front",fx-11,20,6)
  line(fx-25,fy,fx+25,fy,5)
  line(fx,fy-25,fx,fy+25,5)
  circfill(fx+l2x,fy,2,11)
  local tx,ty=96,58
  print("top",tx-8,20,6)
  line(tx-25,ty,tx+25,ty,5)
  line(tx,ty-25,tx,ty+25,5)
  circfill(tx+l2x,ty-l2z,2,11)
  draw_readout({"x: "..l2x,"y: 0","z: "..l2z})
 end
}

-- 3. 2d rotation with sin/cos
lessons[3]={
 init=function()
  l3t=0
 end,
 update=function()
  if btn(0) then l3t-=0.004 end
  if btn(1) then l3t+=0.004 end
 end,
 draw=function()
  draw_header("3. 2d rotation","⬅️➡️ spin the point (turns, not degrees)")
  local ox,oy=64,58
  local r=35
  circ(ox,oy,r,5)
  local px,py=ox+r*cos(l3t),oy+r*sin(l3t)
  line(ox,oy,px,py,6)
  circfill(px,py,2,11)
  draw_readout({
   "t: "..fmt(l3t).." turns",
   "x: "..fmt(r*cos(l3t)),
   "y: "..fmt(r*sin(l3t))
  })
 end
}

-- 4. three axes in 3d
lessons[4]={
 init=function()
  l4ax,l4t=1,0
 end,
 update=function()
  if btn(0) then l4t-=0.004 end
  if btn(1) then l4t+=0.004 end
  if btnp(2) or btnp(3) then l4ax=l4ax%3+1 end
 end,
 draw=function()
  draw_header("4. three axes","⬅️➡️ angle   ⬆️⬇️ axis")
  local ox,oy=64,58
  local rf=rotfns[l4ax]
  local r={}
  for i=1,3 do r[i]=rf(pts3[i],l4t) end
  draw_tri(pts3[1],pts3[2],pts3[3],ox,oy,1)
  draw_tri(r[1],r[2],r[3],ox,oy,7)
  for i=1,3 do circfill(r[i].x+ox,r[i].y+oy,1,11) end
  draw_readout({"axis: "..axnames[l4ax],"angle: "..fmt(l4t).." turns"})
 end
}

-- 5. order matters
lessons[5]={
 init=function()
  l5t=0
 end,
 update=function()
  if btn(0) then l5t-=0.004 end
  if btn(1) then l5t+=0.004 end
 end,
 draw=function()
  draw_header("5. order matters","same angle, different order")
  local ox,oy=64,58
  local a={}
  for i=1,3 do a[i]=roty(rotx(pts3[i],l5t),l5t) end
  local b={}
  for i=1,3 do b[i]=rotx(roty(pts3[i],l5t),l5t) end
  draw_tri(pts3[1],pts3[2],pts3[3],ox,oy,1)
  draw_tri(a[1],a[2],a[3],ox,oy,8)
  draw_tri(b[1],b[2],b[3],ox,oy,12)
  draw_readout({
   "x then y: "..fmt(a[1].x)..","..fmt(a[1].y),
   "y then x: "..fmt(b[1].x)..","..fmt(b[1].y),
   "angle: "..fmt(l5t).." turns"
  })
 end
}

-->8
-- play: quaternion sandbox

play_pts={
 {x=0,y=-42.7,z=0},
 {x=-48,y=21.3,z=0},
 {x=48,y=21.3,z=0}
}
play_piv={x=64,y=75}

play_axes={
 {n="x",x=1,y=0,z=0},
 {n="y",x=0,y=1,z=0},
 {n="z",x=0,y=0,z=1}
}

function play_init()
 play_ai=3
 play_ang=0
end

-- hamilton product
function qmul(a,b)
 return {
  w=a.w*b.w-a.x*b.x-a.y*b.y-a.z*b.z,
  x=a.w*b.x+a.x*b.w+a.y*b.z-a.z*b.y,
  y=a.w*b.y-a.x*b.z+a.y*b.w+a.z*b.x,
  z=a.w*b.z+a.x*b.y-a.y*b.x+a.z*b.w}
end

function qconj(q)
 return {w=q.w,x=-q.x,y=-q.y,z=-q.z}
end

-- axis-angle -> quat
-- t in turns (pico-8 style)
function qaxis(ax,t)
 local h=t/2
 local s,c=-sin(h),cos(h)
 return {w=c,x=ax.x*s,y=ax.y*s,z=ax.z*s}
end

-- v' = q * (0,v) * q^-1
function qrot(q,v)
 local p=qmul(qmul(q,{w=0,x=v.x,y=v.y,z=v.z}),qconj(q))
 return {x=p.x,y=p.y,z=p.z}
end

function update_play()
 if btn(0) then play_ang-=0.004 end
 if btn(1) then play_ang+=0.004 end
 if btnp(4) then play_ai=play_ai%3+1 end
 if btnp(5) then play_ang=0 end
end

function draw_play()
 cls()
 local q=qaxis(play_axes[play_ai],play_ang)
 local r={}
 for i=1,3 do r[i]=qrot(q,play_pts[i]) end

 -- ghost of original (dark)
 for i=1,3 do
  local a,b=play_pts[i],play_pts[i%3+1]
  line(a.x+play_piv.x,a.y+play_piv.y,
       b.x+play_piv.x,b.y+play_piv.y,1)
 end

 -- rotated triangle
 -- orthographic: just drop z
 for i=1,3 do
  local a,b=r[i],r[i%3+1]
  line(a.x+play_piv.x,a.y+play_piv.y,
       b.x+play_piv.x,b.y+play_piv.y,7)
 end
 for i=1,3 do
  local v=r[i]
  rectfill(v.x+play_piv.x-1,v.y+play_piv.y-1,
           v.x+play_piv.x+1,v.y+play_piv.y+1,11)
 end

 print("axis:"..play_axes[play_ai].n.."  ang:"..fmt(play_ang).." turns",1,1,6)
 print("q w:"..fmt(q.w).." x:"..fmt(q.x)
   .." y:"..fmt(q.y).." z:"..fmt(q.z),1,8,12)

 for i=1,3 do
  local p,v=play_pts[i],r[i]
  print(i.." "..fmt(p.x)..","..fmt(p.y)..","..fmt(p.z)
    .." > "..fmt(v.x)..","..fmt(v.y)..","..fmt(v.z),
    1,102+i*7,i==1 and 8 or i==2 and 9 or 10)
 end
 print("❎ axis   🅾️ reset",1,120,5)
end
