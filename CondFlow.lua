--- 条件流程系统

-- 使用约定
-- 1. 添加的条件索引需从0开始，+1递增
-- 2. 成功率优先的条件先行添加

-- 条件必要性
local NEED_REQUIRED = 1 -- 必要条件
local NEED_OPTIONAL = 2 -- 可选条件

-- 条件秩序
local ORDER_ORDINAL = 3 -- 子条件顺序执行
local ORDER_RANDOM = 4 -- 子条件任意执行

-- 条件判断
local JUDGE_ALL = 5 -- 全部子条件满足则该条件达成
local JUDGE_ONE = 6 -- 任一子条件满足则该条件达成

-- 条件
Condition =
{
     need,
     display,
     successRate,
     ok = false,

     New = function(self)
          o = {}
          setmetatable(o, self)
          self.__index = self
          return o
     end,

     Init = function(self)
          self.need = 0
          self.display = 0
          self.successRate = 0
          self.ok = false
     end,

	 -- 是否完成条件
     IsOk = function(self)
          return self.ok
     end,

	 -- 是否满足条件（可选条件无论完成与否都视为满足）
     IsAchieved = function(self)
          if NEED_OPTIONAL == self.need then
               return true
          end
          return self.ok
     end,

	 -- 获取显示信息
     GetDisplay = function(self)
          return self.display
     end,

	 -- 获取成功率
     GetSuccessRate = function(self)
          return self.successRate
     end,
}

-- 条件组
ConditionGroup =
{
     need,
     order,
     judge,
     display,
     prompt,
     successRate,
     size,
     subConds,

     New = function(self)
          local o = {}
          setmetatable(o, self)
          self.__index = self
          return o
     end,

     Init = function(self)
          self.need = 0
          self.order = 0
          self.judge = 0
          display = 0
          prompt = 0
          successRate = 0
          self.size = 0
          self.subConds = {}
     end,

     AddCond = function(self, cond)
          self.subConds[self.size] = cond
          self.size = self.size + 1
     end,

	 -- 是否完成条件
     IsOk = function(self)
          if self.judge == JUDGE_ALL then
               for i = 0, self.size - 1 do
                    if not self.subConds[i]:IsOk() then
                         return false
                    end
               end
               return true
          else
               for i = 0, self.size - 1 do
                    if self.subConds[i]:IsOk() then
                         return true
                    end
               end
               return false
          end
     end,

	 -- 是否满足条件
     IsAchieved = function(self)
          if self.need == NEED_OPTIONAL then
               return true
          end
          if self.judge == JUDGE_ALL then
               for i = 0, self.size - 1 do
                    if not self.subConds[i]:IsAchieved() then
                         return false
                    end
               end
               return true
          else
               for i = 0, self.size - 1 do
                    if self.subConds[i]:IsAchieved() then
                         return true
                    end
               end
               return false
          end
     end,

	 -- 获取显示信息
     GetDisplay = function(self)
          local index = self.size
          local allNo = true
          for i = 0, self.size - 1 do
               if not self.subConds[i]:IsOk() then
                    index = index > i and i or index
               else
                    allNo = false
               end
          end
          if self.display ~= 0 and allNo then
               return self.display
          end
          if index == self.size then
               return self.prompt
          end
          return self.subConds[index]:GetDisplay()
     end,

	 -- 获取成功率
     GetSuccessRate = function(self)
          local totalRate = 0
          if self.judge == JUDGE_ALL then
               for i = 0, self.size - 1 do
                    if self.subConds[i]:IsOk() then
                         totalRate = totalRate + self.subConds[i]:GetSuccessRate()
                    end
               end
               return totalRate + self.successRate
          else
               for i = 0, self.size - 1 do
                    if self.subConds[i]:IsOk() then
                         return self.subConds[i]:GetSuccessRate() + self.successRate
                    end
               end
               return 0
          end
     end,

	 -- 是否可进行该index条件操作
     IsCan = function(self, index)
          if self.order == ORDER_ORDINAL then
               for i = 0, index - 1 do
                    if not self.subConds[i]:IsAchieved() then
                         return false
                    end
               end
          end
          return true
     end,
}


--- 条件流程系统应用示例

-- 功能类型
local STOVE_STRENGTHEN = 1 -- 强化
local STOVE_QUENCH = 2 -- 淬炼
local STOVE_BUFF = 3 -- 注灵

-- 初始化参数表索引
local INIT_EQUIP = 1
local INIT_STONE = 2
local INIT_FW = 3
local INIT_RP = 4
local INIT_BY = 5
local INIT_ALL = 6

-- 条件索引
local INDEX_EQUIP = 0
local INDEX_STONE = 1

local INDEX_BY = 0
local INDEX_FW = 1
local INDEX_RP = 2

-- 初始化参数表
local g_param =
{
     -- 强化
     [STOVE_STRENGTHEN] =
     {
          [INIT_EQUIP] =
          {
               need = NEED_REQUIRED,
               display = "放入装备即可开始",
               successRate = 0,
          },
          [INIT_STONE] =
          {
               need = NEED_REQUIRED,
               display = "放入灵石即可开始",
               successRate = 0,
          },
          [INIT_FW] =
          {
               need = NEED_OPTIONAL,
               display = "放入符文可以增加成功率",
               successRate = 10,
          },
          [INIT_RP] =
          {
               need = NEED_OPTIONAL,
               display = "使用RP可以额外再增加成功率",
               successRate = 0,
          },
          [INIT_BY] =
          {
               need = NEED_REQUIRED,
               order = ORDER_RANDOM,
               judge = JUDGE_ALL,
               display = "放入装备和灵石即可开始",
               prompt = 0,
               successRate = 80,
          },
          [INIT_ALL] =
          {
               need = NEED_REQUIRED,
               order = ORDER_ORDINAL,
               judge = JUDGE_ALL,
               display = 0,
               prompt = "使用RP后你的成功率得到了提升",
               successRate = 0,
          },
     },

     -- 淬炼
     [STOVE_QUENCH] =
     {
          [INIT_EQUIP] =
          {
               need = NEED_REQUIRED,
               display = "放入装备即可开始",
               successRate = 0,
          },
          [INIT_STONE] =
          {
               need = NEED_REQUIRED,
               display = "放入晶髓即可开始",
               successRate = 0,
          },
          [INIT_FW] =
          {
               need = NEED_OPTIONAL,
               display = "放入符文可以增加成功率",
               successRate = 10,
          },
          [INIT_RP] =
          {
               need = NEED_OPTIONAL,
               display = "使用RP可以额外再增加成功率",
               successRate = 0,
          },
          [INIT_BY] =
          {
               need = NEED_REQUIRED,
               order = ORDER_RANDOM,
               judge = JUDGE_ALL,
               display = "放入装备和晶髓即可开始",
               prompt = 0,
               successRate = 80,
          },
          [INIT_ALL] =
          {
               need = NEED_REQUIRED,
               order = ORDER_ORDINAL,
               judge = JUDGE_ALL,
               display = 0,
               prompt = "使用RP后你的成功率得到了提升",
               successRate = 0,
          },
     },

     -- 注灵
     [STOVE_BUFF] =
     {
          [INIT_EQUIP] =
          {
               need = NEED_REQUIRED,
               display = "放入装备即可开始",
               successRate = 0,
          },
          [INIT_STONE] =
          {
               need = NEED_REQUIRED,
               display = "放入器灵即可开始",
               successRate = 0,
          },
          [INIT_FW] =
          {
               need = NEED_OPTIONAL,
               display = "放入符文可以增加成功率",
               successRate = 10,
          },
          [INIT_RP] =
          {
               need = NEED_OPTIONAL,
               display = "使用RP可以额外再增加成功率",
               successRate = 0,
          },
          [INIT_BY] =
          {
               need = NEED_REQUIRED,
               order = ORDER_RANDOM,
               judge = JUDGE_ALL,
               display = "放入装备和器灵即可开始",
               prompt = 0,
               successRate = 80,
          },
          [INIT_ALL] =
          {
               need = NEED_REQUIRED,
               order = ORDER_ORDINAL,
               judge = JUDGE_ALL,
               display = 0,
               prompt = "使用RP后你的成功率得到了提升",
               successRate = 0,
          },
     },
}

-- 条件实例
local condEQ = Condition:New() -- 装备
local condCL = Condition:New() -- 材料
local condFW = Condition:New() -- 符文
local condRP = Condition:New() -- RP
local condGroupBY = ConditionGroup:New() -- 必要条件组
local condGroupAl = ConditionGroup:New() -- 全部条件组

-- 初始化条件实例
function ResetConditions(curStove)
     condEQ:Init()
     condEQ.need           		= g_param[curStove][INIT_EQUIP].need
     condEQ.display           	= g_param[curStove][INIT_EQUIP].display
     condEQ.successRate      	= g_param[curStove][INIT_EQUIP].successRate

     condCL:Init()
     condCL.need           		= g_param[curStove][INIT_STONE].need
     condCL.display           	= g_param[curStove][INIT_STONE].display
     condCL.successRate      	= g_param[curStove][INIT_STONE].successRate

     condFW:Init()
     condFW.need           		= g_param[curStove][INIT_FW].need
     condFW.display          	= g_param[curStove][INIT_FW].display
     condFW.successRate      	= g_param[curStove][INIT_FW].successRate

     condRP:Init()
     condRP.need           		= g_param[curStove][INIT_RP].need
     condRP.display           	= g_param[curStove][INIT_RP].display
     condRP.successRate      	= g_param[curStove][INIT_RP].successRate

     condGroupBY:Init()
     condGroupBY.need        	= g_param[curStove][INIT_BY].need
     condGroupBY.order    		= g_param[curStove][INIT_BY].order
     condGroupBY.judge          = g_param[curStove][INIT_BY].judge
     condGroupBY.display		= g_param[curStove][INIT_BY].display
     condGroupBY.prompt  		= g_param[curStove][INIT_BY].prompt
     condGroupBY.successRate 	= g_param[curStove][INIT_BY].successRate

     condGroupAl:Init()
     condGroupAl.need          	= g_param[curStove][INIT_ALL].need
     condGroupAl.order          = g_param[curStove][INIT_ALL].order
     condGroupAl.judge          = g_param[curStove][INIT_ALL].judge
     condGroupAl.display   		= g_param[curStove][INIT_ALL].display
     condGroupAl.prompt       	= g_param[curStove][INIT_ALL].prompt
     condGroupAl.successRate  	= g_param[curStove][INIT_ALL].successRate
end

-- 当前功能
local g_curStove = STOVE_STRENGTHEN

ResetConditions(STOVE_STRENGTHEN)

condGroupBY:AddCond(condEQ)
condGroupBY:AddCond(condCL)

condGroupAl:AddCond(condGroupBY)
condGroupAl:AddCond(condFW)
condGroupAl:AddCond(condRP)

condEQ.ok = false
condCL.ok = false
condFW.ok = true
condRP.ok = true

print(condGroupAl:IsOk())
print(condGroupAl:IsAchieved())
print(condGroupAl:IsCan(INDEX_FW))
print("Display: " .. condGroupAl:GetDisplay())
print("SuccessRate: " .. condGroupAl:GetSuccessRate())


ResetConditions(STOVE_BUFF)

condGroupBY:AddCond(condEQ)
condGroupBY:AddCond(condCL)

condGroupAl:AddCond(condGroupBY)
condGroupAl:AddCond(condFW)
condGroupAl:AddCond(condRP)

condEQ.ok = true
condCL.ok = true
condFW.ok = true
condRP.ok = true

print(condGroupAl:IsOk())
print(condGroupAl:IsAchieved())
print(condGroupAl:IsCan(INDEX_FW))
print("Display: " .. condGroupAl:GetDisplay())
print("SuccessRate: " .. condGroupAl:GetSuccessRate())
