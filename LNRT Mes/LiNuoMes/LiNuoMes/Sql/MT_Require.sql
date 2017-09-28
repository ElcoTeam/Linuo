/*
select top 20 * 
from 
[dbo].[Log_Mfg_PLC_Tag_Trig]
where category  = 'MT'
AND TAGVALUE ='TRUE'
AND TRIPTIME > '2017-09-18 11:36:10.823'
ORDER BY TAGNAME, TRIPTIME DESC;

SELECT * 
FROM MFG_WO_MTL_PULL
ORDER BY PULLTIME DESC;

    SELECT 
        Mes_PLC_Parameters.*
    FROM 
        Mes_PLC_Parameters
       ,Mes_PLC_List 
    WHERE 
        Mes_PLC_Parameters.PLCID     = Mes_PLC_List.ID
    AND Mes_PLC_List.GoodsCode       = '0000000000'
    AND Mes_PLC_Parameters.ApplModel = 'MT'
    --AND Mes_PLC_Parameters.ParamName = 'LN58.IOBox08.InputBool02'
    ORDER BY PARAMNAME;
*/
    DECLARE @ProcessCode      AS VARCHAR  (50) = '';      
    DECLARE @TagName          AS VARCHAR  (50) ;
    DECLARE @WorkOrderNumber  AS VARCHAR (50);
    DECLARE @WorkOrderVersion AS INT;
    DECLARE @WorkOrderStatus  AS INT;
    DECLARE @GoodsCode        AS VARCHAR (50);
    DECLARE @MesPlanQty       AS INT;             --工单计划产量
    DECLARE @ActionQty        AS NUMERIC (18, 4); --物料已经发送数量
    DECLARE @RequireQty       AS NUMERIC (18, 4); --物料订单需求数量
    DECLARE @ThresholdQty     AS NUMERIC (18, 4); --物料阈值数量
    DECLARE @ApplyQty         AS NUMERIC (18, 4); --物料此次申请数量
    DECLARE @ItemNumber       AS VARCHAR (50);
    DECLARE @UOM              AS NVARCHAR(15);
    DECLARE @ItemDsca         AS NVARCHAR(50);
    DECLARE @WaitingResponse  AS INT;             --当下等待响应的物料拉动记录条数

    DECLARE @NextWorkOrderNumber  AS VARCHAR (50);--下一订单编码
    DECLARE @NextWorkOrderVersion AS INT;         --下一订单版本
    DECLARE @NextWOPlanQty        AS INT;         --下一工单计划产量

    SELECT @TagName = 'LN51.IOBox01.InputBool02'

    --1.查找工序清单, 找到当下的工单, 

    --查找工序, 工单
    SELECT 
        @WorkOrderNumber  = WorkOrderNumber
       ,@WorkOrderVersion = WorkOrderVersion
    FROM 
        Mes_PLC_Parameters
       ,Mes_PLC_List 
    WHERE 
        Mes_PLC_Parameters.PLCID     = Mes_PLC_List.ID
    AND Mes_PLC_List.GoodsCode       = '0000000000'
    AND Mes_PLC_Parameters.ParamName = @TagName;

    SELECT '1', @WORKORDERNUMBER, @WORKORDERVERSION

    --如果工单为空, 则需要进行一下初始化
    IF ISNULL(@WorkOrderNumber, '') = ''
    BEGIN
        SELECT @WorkOrderNumber  = '', @WorkOrderVersion = -1;
        EXEC [usp_Mfg_Wo_List_get_Next_Available] @WorkOrderNumber OUTPUT, @WorkOrderVersion OUTPUT; 
        --EXEC [usp_Mfg_Plc_Param_Update_WO] @TagName, @WorkOrderNumber, @WorkOrderVersion;
    END

    IF ISNULL(@WorkOrderNumber, '') = ''
    BEGIN
        --说明当下没有排程计划. 此时直接返回
        RETURN;
    END 

    EXEC [dbo_Mfg_Plc_Trig_MT_Require] @TagName, @WorkOrderNumber, @WorkOrderVersion, @WorkOrderStatus OUTPUT, @GoodsCode OUTPUT, @MesPlanQty OUTPUT, @ActionQty OUTPUT, @RequireQty OUTPUT, @ThresholdQty OUTPUT, @ItemNumber OUTPUT, @UOM OUTPUT, @ItemDsca OUTPUT, @WaitingResponse OUTPUT;

    
    SELECT '2', @WORKORDERNUMBER, @WORKORDERVERSION, @WaitingResponse

    IF @WaitingResponse > 0 
    BEGIN
        --说明当下, 此工位的此种物料尚有未完成的拉料记录, 因此抛弃此次触发
        RETURN;
    END

    --判断已经拉动的物料数量是否满足了要求
    SET @ApplyQty = @RequireQty - @ActionQty;
    IF @ApplyQty <= 0
    BEGIN
        --如果当下已经完成的拉动请求已经可以满足当下的拉动订单, 则需要取得下一个可以使用的订单. 然后继续进行后续的物料拉动步骤.
        EXEC [usp_Mfg_Wo_List_get_Next_Available] @WorkOrderNumber OUTPUT, @WorkOrderVersion OUTPUT;
        IF ISNULL(@WorkOrderNumber, '') = ''
        BEGIN
            --说明当下没有排程计划. 此时直接返回
            RETURN;
        END 
        --EXEC [usp_Mfg_Plc_Param_Update_WO] @TagName, @WorkOrderNumber, @WorkOrderVersion;
        --EXEC [dbo_Mfg_Plc_Trig_MT_Require] @TagName, @WorkOrderNumber, @WorkOrderVersion, @WorkOrderStatus OUTPUT, @GoodsCode OUTPUT, @MesPlanQty OUTPUT, @ActionQty OUTPUT, @RequireQty OUTPUT, @ThresholdQty OUTPUT, @ItemNumber OUTPUT, @UOM OUTPUT, @ItemDsca OUTPUT, @WaitingResponse OUTPUT;

------------------------------------------------------------------
    SELECT 
         @WorkOrderStatus = MesStatus
        ,@GoodsCode       = ErpGoodsCode
        ,@MesPlanQty      = MesPlanQty
    FROM MFG_WO_List
    WHERE
         ErpWorkOrderNumber  = @WorkOrderNumber
     AND MesWorkOrderVersion = @WorkOrderVersion;

     SELECT 'S1', @GoodsCode

    --得到需要拉动的物料
    SELECT
        @ItemNumber = Mes_PLC_Parameters.ItemNumber     
    FROM 
        Mes_PLC_Parameters
       ,Mes_PLC_List 
    WHERE 
        Mes_PLC_Parameters.PLCID     = Mes_PLC_List.ID
    AND Mes_PLC_List.GoodsCode       = @GoodsCode
    AND Mes_PLC_Parameters.ParamName = @TagName;

    SELECT 'S2', @ItemNumber

    --得到本工单已经拉动物料数量(可能是包含了未确认的, 但是已经响应了的数量)
    SELECT 
        @ActionQty = ISNULL(SUM(ActionQty), 0), @WaitingResponse = ISNULL(SUM(CASE [Status] WHEN 0 THEN 1 ELSE 0 END), 0)
    FROM
        MFG_WO_MTL_Pull
    WHERE 
         WorkOrderNumber   = @WorkOrderNumber
     AND WorkOrderVersion  = @WorkOrderVersion
     AND ItemNumber        = @ItemNumber
     AND [Status]         >= 0;
    
    SELECT 'S3', @ActionQty, @WaitingResponse

    --得到本工单对应此种物料的需求数量
    SELECT 
        @RequireQty = ISNULL(SUM(Qty), 0)
    FROM
        MFG_WO_MTL_List
    WHERE 
         WorkOrderNumber  = @WorkOrderNumber
     AND WorkOrderVersion = @WorkOrderVersion
     AND ItemNumber       = @ItemNumber;   

    SELECT 'S4',  @WorkOrderNumber, @WorkOrderVersion, @ItemNumber, @RequireQty

    --得到本物料的物料拉动阈值.
    SELECT 
        @ThresholdQty = ISNULL(MaxPullQty,100)
       ,@UOM          = ISNULL(UOM,      'EA')
       ,@ItemDsca     = ISNULL(ItemName,  '' )
    FROM
        Mes_Threshold_List
    WHERE
        ItemNumber = @ItemNumber; 

    SELECT 'S5',  @WorkOrderNumber, @WorkOrderVersion, @ItemNumber, @ThresholdQty

--+++++++++++++++++++++++++++++++++++++++++++++++++++++



        SELECT '3', @WORKORDERNUMBER , @WORKORDERVERSION,  @ApplyQty , @RequireQty , @ActionQty, @WaitingResponse waitingresponse

        IF @WaitingResponse > 0 
        BEGIN
            --说明当下, 此工位的此种物料尚有未完成的拉料记录, 因此抛弃此次触发
            RETURN;
        END

        --继续进行补料运算.
        SET @ApplyQty = @RequireQty - @ActionQty;
        IF @ApplyQty <= 0
        BEGIN
            --如果下一个工单仍然已经满足了要求, 说明有另外一个信号同时触发了需求或者本工单物料需求数量过小, 抛弃此次触发.
            RETURN;
        END 
    END 
    
    --最终的拉动请求数量: 剩余需求 与 拉动阈值 二者之中的较小值作为此次的拉动请求数量.
    SET @ApplyQty = (@ApplyQty + @ThresholdQty)/2 - ABS(@ApplyQty - @ThresholdQty)/2;    

    SELECT '4', @WORKORDERNUMBER, @WORKORDERVERSION, @WaitingResponse, @ApplyQty, @ThresholdQty, @RequireQty

    --取得下一工单的相应信息.
    SELECT @NextWorkOrderNumber = @WorkOrderNumber, @NextWorkOrderVersion = @WorkOrderVersion;
    EXEC [usp_Mfg_Wo_List_get_Next_Available] @NextWorkOrderNumber OUTPUT, @NextWorkOrderVersion OUTPUT;

    SELECT @NextWOPlanQty = ISNULL(MesPlanQty, 0)
    FROM MFG_WO_List
    WHERE
            ErpWorkOrderNumber  = @NextWorkOrderNumber
        AND MesWorkOrderVersion = @NextWorkOrderVersion;

    SELECT '5', @WORKORDERNUMBER, @WORKORDERVERSION, @NextWorkOrderNumber, @NextWorkOrderVersion, @NextWOPlanQty, @WaitingResponse, @ApplyQty, @ThresholdQty, @RequireQty
    
    --如果当下工单的状态为"待生产", 则需要设置工单为"产前调整中",
    
    -- IF @WorkOrderStatus = 0 
    -- BEGIN
    --     UPDATE MFG_WO_List 
    --     SET 
    --         MesStatus = 1 
    --     WHERE
    --         ErpWorkOrderNumber  = @WorkOrderNumber
    --     AND MesWorkOrderVersion = @WorkOrderVersion
    --     AND MesStatus           = 0; --此条件不可以省略, 因为我们是提前获取状态的时候, 当时并没有为表加锁.
    -- END

    --产生物料拉料动作.
    SELECT '6', @WorkOrderNumber, @WorkOrderVersion, @NextWorkOrderNumber, @NextWorkOrderVersion, @NextWOPlanQty, @ActionQty,      @ItemNumber, @ItemDsca, @ProcessCode, @UOM, @ApplyQty, 'MES';
    --(需要判断当前是否为全局"暂停/正常"标志, 此处涉及到异常恢复情况场景, 比较复杂, 时间关系不考虑)