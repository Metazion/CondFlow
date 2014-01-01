--- ��������ϵͳ

-- ʹ��Լ��
-- 1. ��ӵ������������0��ʼ��+1����
-- 2. �ɹ������ȵ������������

-- ������Ҫ��
local NEED_REQUIRED = 1 -- ��Ҫ����
local NEED_OPTIONAL = 2 -- ��ѡ����

-- ��������
local ORDER_ORDINAL = 3 -- ������˳��ִ��
local ORDER_RANDOM = 4 -- ����������ִ��

-- �����ж�
local JUDGE_ALL = 5 -- ȫ����������������������
local JUDGE_ONE = 6 -- ��һ��������������������

-- ����
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

	 -- �Ƿ��������
     IsOk = function(self)
          return self.ok
     end,

	 -- �Ƿ�������������ѡ����������������Ϊ���㣩
     IsAchieved = function(self)
          if NEED_OPTIONAL == self.need then
               return true
          end
          return self.ok
     end,

	 -- ��ȡ��ʾ��Ϣ
     GetDisplay = function(self)
          return self.display
     end,

	 -- ��ȡ�ɹ���
     GetSuccessRate = function(self)
          return self.successRate
     end,
}

-- ������
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

	 -- �Ƿ��������
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

	 -- �Ƿ���������
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

	 -- ��ȡ��ʾ��Ϣ
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

	 -- ��ȡ�ɹ���
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

	 -- �Ƿ�ɽ��и�index��������
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


--- ��������ϵͳӦ��ʾ��

-- ��������
local STOVE_STRENGTHEN = 1 -- ǿ��
local STOVE_QUENCH = 2 -- ����
local STOVE_BUFF = 3 -- ע��

-- ��ʼ������������
local INIT_EQUIP = 1
local INIT_STONE = 2
local INIT_FW = 3
local INIT_RP = 4
local INIT_BY = 5
local INIT_ALL = 6

-- ��������
local INDEX_EQUIP = 0
local INDEX_STONE = 1

local INDEX_BY = 0
local INDEX_FW = 1
local INDEX_RP = 2

-- ��ʼ��������
local g_param =
{
     -- ǿ��
     [STOVE_STRENGTHEN] =
     {
          [INIT_EQUIP] =
          {
               need = NEED_REQUIRED,
               display = "����װ�����ɿ�ʼ",
               successRate = 0,
          },
          [INIT_STONE] =
          {
               need = NEED_REQUIRED,
               display = "������ʯ���ɿ�ʼ",
               successRate = 0,
          },
          [INIT_FW] =
          {
               need = NEED_OPTIONAL,
               display = "������Ŀ������ӳɹ���",
               successRate = 10,
          },
          [INIT_RP] =
          {
               need = NEED_OPTIONAL,
               display = "ʹ��RP���Զ��������ӳɹ���",
               successRate = 0,
          },
          [INIT_BY] =
          {
               need = NEED_REQUIRED,
               order = ORDER_RANDOM,
               judge = JUDGE_ALL,
               display = "����װ������ʯ���ɿ�ʼ",
               prompt = 0,
               successRate = 80,
          },
          [INIT_ALL] =
          {
               need = NEED_REQUIRED,
               order = ORDER_ORDINAL,
               judge = JUDGE_ALL,
               display = 0,
               prompt = "ʹ��RP����ĳɹ��ʵõ�������",
               successRate = 0,
          },
     },

     -- ����
     [STOVE_QUENCH] =
     {
          [INIT_EQUIP] =
          {
               need = NEED_REQUIRED,
               display = "����װ�����ɿ�ʼ",
               successRate = 0,
          },
          [INIT_STONE] =
          {
               need = NEED_REQUIRED,
               display = "���뾧�輴�ɿ�ʼ",
               successRate = 0,
          },
          [INIT_FW] =
          {
               need = NEED_OPTIONAL,
               display = "������Ŀ������ӳɹ���",
               successRate = 10,
          },
          [INIT_RP] =
          {
               need = NEED_OPTIONAL,
               display = "ʹ��RP���Զ��������ӳɹ���",
               successRate = 0,
          },
          [INIT_BY] =
          {
               need = NEED_REQUIRED,
               order = ORDER_RANDOM,
               judge = JUDGE_ALL,
               display = "����װ���;��輴�ɿ�ʼ",
               prompt = 0,
               successRate = 80,
          },
          [INIT_ALL] =
          {
               need = NEED_REQUIRED,
               order = ORDER_ORDINAL,
               judge = JUDGE_ALL,
               display = 0,
               prompt = "ʹ��RP����ĳɹ��ʵõ�������",
               successRate = 0,
          },
     },

     -- ע��
     [STOVE_BUFF] =
     {
          [INIT_EQUIP] =
          {
               need = NEED_REQUIRED,
               display = "����װ�����ɿ�ʼ",
               successRate = 0,
          },
          [INIT_STONE] =
          {
               need = NEED_REQUIRED,
               display = "�������鼴�ɿ�ʼ",
               successRate = 0,
          },
          [INIT_FW] =
          {
               need = NEED_OPTIONAL,
               display = "������Ŀ������ӳɹ���",
               successRate = 10,
          },
          [INIT_RP] =
          {
               need = NEED_OPTIONAL,
               display = "ʹ��RP���Զ��������ӳɹ���",
               successRate = 0,
          },
          [INIT_BY] =
          {
               need = NEED_REQUIRED,
               order = ORDER_RANDOM,
               judge = JUDGE_ALL,
               display = "����װ�������鼴�ɿ�ʼ",
               prompt = 0,
               successRate = 80,
          },
          [INIT_ALL] =
          {
               need = NEED_REQUIRED,
               order = ORDER_ORDINAL,
               judge = JUDGE_ALL,
               display = 0,
               prompt = "ʹ��RP����ĳɹ��ʵõ�������",
               successRate = 0,
          },
     },
}

-- ����ʵ��
local condEQ = Condition:New() -- װ��
local condCL = Condition:New() -- ����
local condFW = Condition:New() -- ����
local condRP = Condition:New() -- RP
local condGroupBY = ConditionGroup:New() -- ��Ҫ������
local condGroupAl = ConditionGroup:New() -- ȫ��������

-- ��ʼ������ʵ��
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

-- ��ǰ����
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
