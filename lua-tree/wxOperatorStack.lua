local wxOperatorStack  = class ("wxOperatorStack")

-- 定义一个操作栈
function wxOperatorStack:create()
    local stack = wxOperatorStack.new()
    stack:init()
    return stack
end

--初始化
function wxOperatorStack:init()
    self.undoStack = {}
    self.redoStack = {}
end

-- 定义一个保存操作的方法
function wxOperatorStack:pushOperation(operation)
    -- 当前操作压入undo栈
    table.insert(self.undoStack, operation)
    -- 清空redo栈，因为新的操作使得之前的redo无效
    self.redoStack = {}
end

-- 定义回撤函数
function wxOperatorStack:undo()
    if #self.undoStack > 0 then
        local lastOperation = table.remove(self.undoStack)
        -- 假设operation是一个函数，可以撤销之前的操作
        lastOperation.undo()
        -- 将撤销的操作推入redo栈，以便后续可能的重做
        table.insert(self.redoStack, lastOperation)
    end
end

-- 定义重做函数
function wxOperatorStack:redo()
    if #self.redoStack > 0 then
        local nextOperation = table.remove(self.redoStack)
        nextOperation.redo()

        -- 重做的操作重新加入undo栈
        table.insert(self.undoStack, nextOperation)
    end
end

return wxOperatorStack