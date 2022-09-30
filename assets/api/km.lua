---@meta

---@class lkazmath
lkazmath = {}

---@class kmAABB2
local kmAABB2 = {}

---@return kmAABB2 the AABB2
function lkazmath.kmAABB2New() end

---@param aabb2 kmAABB2 the AABB2
---@param center kmVec2 the center of the AABB2
---@param width number the width
---@param height number the height
---@param depth number the depth. It is ignored.
function lkazmath.kmAABB2Initialize(aabb2, center, width, height, depth) end


---@class kmVec2
local kmVec2 = {}

---@return kmVec2 the vector
function lkazmath.kmVec2New() end



---@class kmMat4
local kmMat4 = {}

---@return kmMat4 the 4x4 matrix
function lkazmath.kmMat4New() end

---@param mat kmMat4 the 4x4 matrix to set as an identity
function lkazmath.kmMat4Identity(mat) end

