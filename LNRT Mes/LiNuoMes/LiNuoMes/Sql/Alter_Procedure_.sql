
--取得SAP出错回馈信息
ALTER PROCEDURE  [dbo].[usp_Sap_Error_Information]
      @RFCName        AS VARCHAR(50) = '' 
     ,@StdCode        AS VARCHAR(50) = '' 
AS
    SELECT
         [InTime]  InTime  
        ,[StdCode] StdCode 
        ,[Row]     ErrRow 
        ,[Type]    ErrType 
        ,[Message] ErrMessage 
    FROM SapErrorInformation
    WHERE
        RIGHT([RFCName] ,13) = RIGHT(@RFCName, 13)
    AND
    ( 
        ( RIGHT(@StdCode,8) = RIGHT(StdCode,8) )
    OR  ( @StdCode = '' AND InTime > GETDATE() - 2 ) 
    )
    ORDER BY [InTime] DESC, ErrRow
GO

--取得反冲料物料料号清单
ALTER PROCEDURE  [dbo].[usp_Mfg_Wip_Bkf_Item_List]
AS
    SELECT
         *
    FROM MFG_WIP_BKF_Item_List
    WHERE
        [Status] > -2
    ORDER BY ItemNumber
GO

--编辑反冲物料料号的详细信息
ALTER PROCEDURE  [dbo].[usp_Mfg_Wip_Bkf_Item_List_Add]
     @ItemId           AS INT
    ,@ItemNumber       AS VARCHAR  (50)
    ,@ItemDsca         AS NVARCHAR (50)
    ,@UOM              AS VARCHAR  (15)
    ,@UserName         AS VARCHAR  (50)
    ,@CatchError       AS INT           OUTPUT --系统判断用户操作异常的数量
    ,@RtnMsg           AS NVARCHAR(100) OUTPUT --返回状态
AS
    SET @CatchError = 0
    SET @RtnMsg     = ''

    --检查此Item的ID是否存在.
    DECLARE @ExistCount   INT;

    SELECT @ItemNumber = UPPER(LTRIM(RTRIM(@ItemNumber))), @ItemDsca = LTRIM(RTRIM(@ItemDsca)), @UOM = UPPER(LTRIM(RTRIM(@UOM)));

    SELECT 
        @ExistCount = COUNT(1) 
    FROM 
        MFG_WIP_BKF_Item_List
    WHERE 
        ItemNumber = @ItemNumber
                           
    IF @ExistCount > 0 
    BEGIN
        SET @CatchError = 1;
        SET @RtnMsg = '您刚刚录入的料号在系统中已经存在, 请您确认是否发生了重复!';
        RETURN;
    END

    INSERT INTO MFG_WIP_BKF_Item_List 
            (ItemNumber, ItemDsca,  UOM,  CreateTime, CreateUser)
    VALUES( @ItemNumber, @ItemDsca, @UOM, GETDATE(),  @UserName);
GO


--编辑反冲物料料号的详细信息
ALTER PROCEDURE  [dbo].[usp_Mfg_Wip_Bkf_Item_List_Edit]
     @ItemId           AS INT
    ,@ItemNumber       AS VARCHAR  (50)
    ,@ItemDsca         AS NVARCHAR (50)
    ,@UOM              AS VARCHAR  (15)
    ,@UserName         AS VARCHAR  (50)
    ,@CatchError       AS INT           OUTPUT --系统判断用户操作异常的数量
    ,@RtnMsg           AS NVARCHAR(100) OUTPUT --返回状态
AS
    SET @CatchError = 0
    SET @RtnMsg     = ''

    --检查此Item的ID是否存在.
    DECLARE @ExistCount   INT;

    SELECT @ItemNumber = UPPER(LTRIM(RTRIM(@ItemNumber))), @ItemDsca = LTRIM(RTRIM(@ItemDsca)), @UOM = UPPER(LTRIM(RTRIM(@UOM)));

    SELECT 
        @ExistCount = COUNT(1) 
    FROM 
        MFG_WIP_BKF_Item_List
    WHERE 
        ID = @ItemId
                            
    IF @ExistCount = 0 
    BEGIN
        SET @CatchError = 1;
        SET @RtnMsg = '系统没有发现您要更改的料![ID=' + CONVERT(VARCHAR, @ItemId) + ']';
        RETURN;
    END

    SELECT 
        @ExistCount = COUNT(1) 
    FROM 
        MFG_WIP_BKF_Item_List
    WHERE 
        ItemNumber = @ItemNumber
    AND ID <> @ItemId
                            
    IF @ExistCount > 0 
    BEGIN
        SET @CatchError = 1;
        SET @RtnMsg = '您刚刚录入的料号在系统中已经存在, 请您确认是否发生了重复!';
        RETURN;
    END

    UPDATE MFG_WIP_BKF_Item_List
    SET ItemNumber = @ItemNumber
       ,ItemDsca   = @ItemDsca
       ,UOM        = @UOM
       ,ModifyTime = GETDATE()
       ,ModifyUser = @UserName
    WHERE 
        ID = @ItemId 
GO

--删除反冲物料料号的详细信息
ALTER PROCEDURE  [dbo].[usp_Mfg_Wip_Bkf_Item_List_Delete]
     @ItemId             AS INT                  --待删除记录的ID
    ,@CatchError         AS INT           OUTPUT --系统判断用户操作异常的数量
    ,@RtnMsg             AS NVARCHAR(100) OUTPUT --返回状态
AS
    SET @CatchError = 0
    SET @RtnMsg     = ''

    BEGIN TRANSACTION

    DECLARE @GoodsCode VARCHAR(50);

    IF (SELECT COUNT(1) FROM MFG_WIP_BKF_Item_List WHERE ID = @ItemId) > 0
    BEGIN
        DELETE FROM MFG_WIP_BKF_Item_List WHERE ID = @ItemId;
    END

    COMMIT TRANSACTION
    RETURN
GO

--取得反冲料物料料号建议的描述信息: 此存储过程在新增反冲物料的时候会建议用户使用.
ALTER PROCEDURE  [dbo].[usp_Mfg_Wip_Bkf_Item_Suggest_Dsca]
    @ItemNumber       AS VARCHAR  (50)
AS
    SELECT
        DISTINCT ItemNumber, ItemDsca
    FROM 
        MFG_WO_MTL_List
    WHERE
         ItemNumber = @ItemNumber
    -- AND Backflush = 'X'
    ORDER BY ItemNumber
GO

--取得反冲料物料料号的详细信息
ALTER PROCEDURE  [dbo].[usp_Mfg_Wip_Bkf_Item_Detail]
    @ItemId    AS INT=0 
AS
    SELECT
         *
    FROM MFG_WIP_BKF_Item_List
    WHERE
        ID = @ItemId
    ORDER BY ItemNumber
GO

--取得当日生产排程计划
ALTER PROCEDURE  [dbo].[usp_Mfg_Wo_List_get_today]
AS
    SELECT
         ID
        ,ErpWorkOrderNumber WorkOrderNumber
        ,MesWorkOrderVersion WorkOrderVersion
        ,ErpGoodsCode GoodsCode 
        ,ErpGoodsDsca GoodsDsca
        ,FORMAT(MesPlanStartTime, 'yyyy-MM-dd hh:mm')  PlanStartTime
        ,FORMAT(MesPlanFinishTime,'yyyy-MM-dd hh:mm')  PlanFinishTime
        ,MesCostTime CostTime
        ,MesPlanQty PlanQty
        ,MesInturnNumber InturnNumber
        ,MesWorkOrderType WorkOrderType
        ,MesFinishQty FinishQty
        ,MesStartPoint StartPoint
        ,MesStatus Status
        ,Mes2ErpMVTStatus Mes2ErpMVTStatus
    FROM MFG_WO_List
    WHERE
        CONVERT(DATE, ErpPlanStartTime) = CONVERT(DATE, GETDATE())
        OR ( MesStatus < 3 AND MesStatus >= 0 )
    
 --   --制造一些演示调试数据
 -- UNION ALL SELECT '3','000020075730','000000003070200184','2017-05-1608:00','2017-05-1610:15','135','50','3','0','30','3'
 -- UNION ALL SELECT '1','1','1','1','1','1','1','1','0','1','0','2','2'
 -- UNION ALL SELECT '2','2','2','2','2','2','2','2','0','1','2','2','2'
 -- UNION ALL SELECT '4','4','4','4','4','4','4','4','1','1','1','2','2'

ORDER BY InturnNumber

GO

--获取下一个可以使用的订单, 这里可以使用是指:依据生产排程获取的最早的订单, 其处于状态: 待生产, 产前调整中, 生产进行中
--此时, 可以在如下事件中发生: 生产产出, 物料拉动, 参数派发等动作(因此上, 最少有如上三处会调用此存储过程).
--如果当下的订单为空, 则取得第一个可以使用的订单.
-- 使用范例:
-- DECLARE @WorkOrderNumber  AS VARCHAR(50);
-- DECLARE @WorkOrderVersion AS INT        ;
-- SELECT @WorkOrderNumber = '20075731', @WorkOrderVersion = 1;  --初始化当下正在使用的订单
-- EXEC [usp_Mfg_Wo_List_get_Next_Available] @WorkOrderNumber OUTPUT, @WorkOrderVersion OUTPUT;
-- SELECT @WorkOrderNumber,@WorkOrderVersion
ALTER PROCEDURE  [dbo].[usp_Mfg_Wo_List_get_Next_Available]
      @WorkOrderNumber        AS VARCHAR(50) = '' OUTPUT
     ,@WorkOrderVersion       AS INT         = -1 OUTPUT
AS
   DECLARE @itnCurr AS INT;
   DECLARE @itnNext AS INT;
   DECLARE @itn     AS INT;
    
    --先取出当下的订单条目
    SELECT @itnCurr = MIN(MesInturnNumber)
    FROM MFG_WO_List
    WHERE
        (ErpWorkOrderNumber  = @WorkOrderNumber )
    AND (MesWorkOrderVersion = @WorkOrderVersion)
    
    IF ISNULL(@itnCurr, 0) > 0 
    BEGIN
        --取得临近的排产的下一个订单条目
        SELECT @itnNext = MIN(MesInturnNumber)
        FROM MFG_WO_List
        WHERE
            ( CONVERT(DATE, ErpPlanStartTime) = CONVERT(DATE, GETDATE()) OR ( MesStatus < 3 AND MesStatus >= 0 ))
        AND MesInturnNumber > @itnCurr
    END
    ELSE
    BEGIN
        --如果当下的订单没有找到的情况下, 则把第一条可以排产的订单找出来.
        SELECT @itnCurr = MIN(MesInturnNumber)
        FROM MFG_WO_List
        WHERE
            ( CONVERT(DATE, ErpPlanStartTime) = CONVERT(DATE, GETDATE()) OR ( MesStatus < 3 AND MesStatus >= 0 ))
    END

    IF ISNULL(@itnNext, 0) > 0 
    BEGIN
        SET @itn = @itnNext;
    END
    ELSE
    BEGIN
        SET @itn = @itnCurr;
    END
    
    IF ISNULL(@itn, 0) > 0 
    BEGIN
       --取出详细的订单条目
       SELECT 
             @WorkOrderNumber  = ErpWorkOrderNumber
            ,@WorkOrderVersion = MesWorkOrderVersion
       FROM MFG_WO_List  
       WHERE @itn = MesInturnNumber         
    END 
    ELSE
    BEGIN
        --说明当下没有任何排程信息
        SELECT
             @WorkOrderNumber  = ''
            ,@WorkOrderVersion = -1
    END
GO

--取得需要进行完工报工的生产排程计划
ALTER PROCEDURE  [dbo].[usp_Mfg_Wo_List_Mvt]
      @WorkOrderNumber        AS VARCHAR(50) = ''
     ,@PlanDate               AS VARCHAR(50) = ''
AS
    SELECT
         ID
        ,MesInturnNumber InturnNumber
        ,ErpWorkOrderNumber WorkOrderNumber
        ,MesWorkOrderVersion WorkOrderVersion
        ,ErpGoodsCode GoodsCode 
        ,ErpGoodsDsca GoodsDsca
        ,FORMAT(MesPlanStartTime, 'yyyy-MM-dd')  PlanStartTime
        ,MesWorkOrderType WorkOrderType
        ,MesPlanQty PlanQty
        ,Mes2ErpMVTStatus Mes2ErpMVTStatus
        ,CASE Mes2ErpMVTStatus
             WHEN  3 THEN '按单发料完成'    
             WHEN  2 THEN '按单发料失败!!!'
             WHEN  1 THEN '按单发料进行中...'
             WHEN  0 THEN '等待按单发料...'
             WHEN -1 THEN ''            -- 新ERP工单或者补单产生的初始化时是这个状态, 此时没有必要给用户提示任何信息
             ELSE         '系统未知'     -- 备用
         END AS MVTMsg
        ,CASE            
             WHEN Mes2ErpMVTStatus = -1 THEN 'DOMVT'
             WHEN Mes2ErpMVTStatus =  2 THEN 'REDO'
             ELSE                            'SHOWTIP'
         END AS EnableMVT
    FROM MFG_WO_List
    WHERE
    (   --非初始化条件下, 使用过滤条件作为查询结果
            (ErpWorkOrderNumber = @WorkOrderNumber OR @WorkOrderNumber = '' )
        AND (DATEDIFF(DAY, MesPlanStartTime, CONVERT(DATE, @PlanDate)) = 0 OR @PlanDate = '' ) 
    )
    AND 
    (   -- 初始化条件下, 以完成产量和已报工差值作为判断条件
            ( 
              Mes2ErpMVTStatus <> 3 AND @WorkOrderNumber = '' AND @PlanDate = ''
            )
        OR  ( @WorkOrderNumber <> '' OR @PlanDate <> '' )
    )
    AND MesWorkOrderVersion = 0
    ORDER BY InturnNumber
GO

--取得需要进行完工报工的生产排程计划
ALTER PROCEDURE  [dbo].[usp_Mfg_Wo_List_Roc]
      @WorkOrderNumber        AS VARCHAR(50) = ''
     ,@PlanDate               AS VARCHAR(50) = ''
AS
    SELECT
         ID
        ,MesInturnNumber InturnNumber
        ,ErpWorkOrderNumber WorkOrderNumber
        ,MesWorkOrderVersion WorkOrderVersion
        ,ErpGoodsCode GoodsCode 
        ,ErpGoodsDsca GoodsDsca
        ,FORMAT(MesPlanStartTime, 'yyyy-MM-dd')  PlanStartTime
        ,MesWorkOrderType WorkOrderType
        ,MesPlanQty PlanQty
        ,MesFinishQty FinishQty
        ,Mes2ErpCfmQty Mes2ErpCfmQty
        ,(ABS(MesFinishQty + MesPlanQty) - ABS(MesFinishQty - MesPlanQty))/2 - Mes2ErpCfmQty ROCQty
        ,CASE Mes2ErpCfmStatus
             WHEN  3 THEN '报工完成'     
             WHEN  2 THEN '报工失败!!!'     
             WHEN  1 THEN '报工进行中...'
             WHEN  0 THEN '等待报工...'
             WHEN -1 THEN ''            -- 新ERP工单或者补单产生的初始化时是这个状态, 此时没有必要给用户提示任何信息
             ELSE         '系统未知'     -- 备用
         END AS ROCMsg
        ,CASE            
             WHEN     ( Mes2ErpCfmStatus = 3 OR Mes2ErpCfmStatus = -1 ) 
                  AND ((ABS(MesFinishQty + MesPlanQty) - ABS(MesFinishQty - MesPlanQty))/2 - Mes2ErpCfmQty > 0 )
                                       THEN 'DOROC'
             WHEN Mes2ErpCfmStatus = 2 THEN 'REDO'
             ELSE                           'SHOWTIP'
         END AS EnableROC
    FROM MFG_WO_List
    WHERE
    (   --非初始化条件下, 使用过滤条件作为查询结果
            (ErpWorkOrderNumber = @WorkOrderNumber OR @WorkOrderNumber = '' )
        AND (DATEDIFF(DAY, MesPlanStartTime, CONVERT(DATE, @PlanDate)) = 0 OR @PlanDate = '' ) 
    )
    AND 
    (   -- 初始化条件下, 以完成产量和已报工差值作为判断条件
            ( 
              ((ABS(MesFinishQty + MesPlanQty) - ABS(MesFinishQty - MesPlanQty))/2 - Mes2ErpCfmQty > 0 OR Mes2ErpCfmStatus <> 3
              ) AND @WorkOrderNumber = '' AND @PlanDate = ''
            )
        OR  ( @WorkOrderNumber <> '' OR @PlanDate <> '' )
    )
    ORDER BY InturnNumber
GO

--取得产品编码管理的物料拉动绑定物料(附属物料)清单
ALTER PROCEDURE  [dbo].[usp_Mes_Mtl_Pull_Item_Attached]
     @GoodsCode       AS VARCHAR(50)  = '',
     @MainItem        AS VARCHAR(50)  = ''
AS
    SELECT * 
    FROM 
        Mes_Mtl_Pull_Item_Attached 
    where 
        GoodsCode = @GoodsCode
    AND MainItem = @MainItem
    ORDER BY
        ItemNumber;
GO


--取得下线补单的详细信息.
ALTER PROCEDURE  [dbo].[usp_Mfg_Wo_List_SubPlan]
      @WorkOrderNumber        AS VARCHAR(50)
     ,@PlanDate               AS VARCHAR(50)
AS
    IF @PlanDate = ''
    BEGIN
        SET @PlanDate = FORMAT(GETDATE(), 'yyyy-MM-dd hh:mm');
    END
    SELECT
         WO.ID
        ,WO.ErpWorkOrderNumber WorkOrderNumber
        ,WO.MesWorkOrderVersion WorkOrderVersion
        ,WO.ErpGoodsCode GoodsCode
        ,FORMAT(WO.MesPlanStartTime, 'yyyy-MM-dd hh:mm') PlanStartTime
        ,FORMAT(WO.MesPlanFinishTime,'yyyy-MM-dd hh:mm') PlanFinishTime
        ,WO.MesCostTime CostTime
        ,WO.MesPlanQty PlanQty
        ,WO.MesInturnNumber InturnNumber
        ,WO.MesWorkOrderType WorkOrderType
        ,WO.MesFinishQty FinishQty
        ,WO.MesStatus Status
        ,WO.MesSubPlanFlag SubPlanFlag
        ,WO.MesStartPoint StartPoint
        ,MesDiscardQty1 + MesDiscardQty1 + MesDiscardQty3 + MesDiscardQty4  DiscardQty
        ,MesLeftQty1   LeftQty1
        ,MesLeftQty2   LeftQty2
        ,MesLeftQty3   LeftQty3
        ,MesLeftQty4   LeftQty4
    FROM 
        MFG_WO_List AS WO 
    WHERE            
            (DATEDIFF(DAY, WO.MesPlanStartTime, CONVERT(DATE, @PlanDate)) = 0 OR WO.MesStatus = 3 ) 
        AND (WO.ErpWorkOrderNumber = @WorkOrderNumber OR @WorkOrderNumber='')
        AND MesDiscardQty1 + MesDiscardQty1 + MesDiscardQty3 + MesDiscardQty4 
          + MesLeftQty1    + MesLeftQty2    + MesLeftQty3    + MesLeftQty4 > 0
        
ORDER BY InturnNumber

GO

--取得异常下线的产品阶段清单
ALTER PROCEDURE  [dbo].[usp_Mfg_Wip_Data_Abnormal_Product_List]
     @abPointID       AS INT         = 0
AS
    SELECT PR.* 
    FROM 
    MFG_WIP_Data_Abnormal_Product PR,
    MFG_WIP_Data_Abnormal_Point_Product PM
    where PR.ID = PM.abProductID
    AND PM.abPointID = @abPointID
GO

--取得异常下线的下线原因清单
ALTER PROCEDURE  [dbo].[usp_Mfg_Wip_Data_Abnormal_Reason_List]
     @AbId            AS INT  = 0
    ,@abProduct       AS INT  = 0
AS
    SELECT 
         TT.DisplayValue DisplayValue
        ,TT.ID TemplateID
        ,AB.RecordValue RecordValue
    FROM MFG_WIP_Data_Abnormal_Reason_Template TT
    LEFT JOIN MFG_WIP_Data_Abnormal_Reason AB ON TT.ID = AB.TemplateID AND AB.AbnormalID = @AbId
    WHERE TT.AbProductID = @abProduct
    ORDER BY TT.ID;
GO

ALTER PROCEDURE  [dbo].[usp_Mfg_Wip_Data_Abnormal_SummayQty]
      @WorkOrderNumber        AS VARCHAR(50) = ''
     ,@WorkOrderVersion       AS INT         = -1
AS
    SELECT 
        WorkOrderNumber,
        WorkOrderVersion,
        SUM(
            CASE 
            WHEN AbnormalPoint = 1 AND AbnormalType = 3 THEN 1 
            ELSE 0
            END 
        ) AS LeftQty1
        ,SUM(
            CASE 
            WHEN AbnormalPoint = 2 AND AbnormalType = 3 THEN 1
            ELSE 0
            END 
        ) AS LeftQty2
        ,SUM(
            CASE 
            WHEN AbnormalPoint = 3 AND AbnormalType = 3 THEN 1 
            ELSE 0
            END 
        ) AS LeftQty3
        ,SUM(
            CASE 
            WHEN AbnormalPoint = 4 AND AbnormalType = 3 THEN 1
            ELSE 0
            END 
        ) AS LeftQty4
        ,SUM(
            CASE   
            WHEN AbnormalPoint = 1 AND AbnormalType = 2 THEN 1 
            ELSE 0 
            END 
        ) AS DiscardQty1
        ,SUM(
            CASE   
            WHEN AbnormalPoint = 2 AND AbnormalType = 2 THEN 1 
            ELSE 0 
            END 
        ) AS DiscardQty2
        ,SUM(
            CASE   
            WHEN AbnormalPoint = 3 AND AbnormalType = 2 THEN 1 
            ELSE 0 
            END 
        ) AS DiscardQty3
        ,SUM(
            CASE   
            WHEN AbnormalPoint = 4 AND AbnormalType = 2 THEN 1 
            ELSE 0 
            END 
        ) AS DiscardQty4
    FROM 
        MFG_WIP_Data_Abnormal
    WHERE 
        AbnormalType >=2  --只计算报废或未完工两种下线情况, 补修不计算在内
        AND (@WorkOrderNumber  = WorkOrderNumber  OR @WorkOrderNumber  = '')
        AND (@WorkOrderVersion = WorkOrderVersion OR @WorkOrderVersion = -1)
    GROUP BY 
        WorkOrderNumber, WorkOrderVersion    
GO

--创建下线补单的表头部分.完成下线补单的创建需要两个存储过程配合使用才能完成.
--创建下线补单的用料部分的存储过程为: usp_Mfg_Wo_Mtl_List_Add_SubPlan
ALTER PROCEDURE  [dbo].[usp_Mfg_Wo_List_Add_SubPlan]
      @WoId                   AS INT
     ,@UserName               AS VARCHAR(50)
     ,@WorkOrderNumber        AS VARCHAR(50)   OUTPUT
     ,@WorkOrderVersion       AS INT           OUTPUT
     ,@CatchError             AS INT           OUTPUT --系统判断用户操作异常的数量
     ,@RtnMsg                 AS NVARCHAR(100) OUTPUT --返回状态
AS
    SET @CatchError = 0
    SET @RtnMsg     = ''
    SET @WorkOrderNumber  = ''
    SET @WorkOrderVersion = 0

    DECLARE @MesStatus      INT;
    DECLARE @MesSubPlanFlag INT;
    DECLARE @MesStartPoint  VARCHAR(50);

    SELECT
        @WorkOrderNumber  = ErpWorkOrderNumber,
        @WorkOrderVersion = MesWorkOrderVersion,
        @MesStatus        = MesStatus,
        @MesSubPlanFlag   = MesSubPlanFlag
    FROM
        MFG_WO_List
    WHERE 
        ID = @WoId

    IF @WorkOrderNumber = '' 
    BEGIN
        SET @CatchError = @CatchError + 1;
        SET @RtnMsg = '您选择的订单并不存在, 请检查核对!';
        RETURN;
    END

    IF @MesStatus < 3 
    BEGIN
        SET @CatchError = @CatchError + 1;
        SET @RtnMsg = '您选择的订单目前不是“已完成”状态, 因此现在还不可以创建下线补单!';
        RETURN;        
    END
/**/
    IF @MesSubPlanFlag > 0
    BEGIN
        SET @CatchError = @CatchError + 1;
        SET @RtnMsg = '您选择的订单已经创建过下线补单, 一个订单不可以重复创建下线补单!';
        RETURN;
    END 

    DECLARE @StartPoint  VARCHAR(50);
    DECLARE @APO1        INT;
    DECLARE @APO2        INT;
    DECLARE @APO3        INT;
    DECLARE @APO4        INT;
    DECLARE @ATY2        INT;
    DECLARE @ATY3        INT;
    DECLARE @PlanQty     INT;


    --选择上线工序
    SELECT
         @APO1    = SUM(CASE AbnormalPoint WHEN  1  THEN 1 ELSE 0 END ),
         @APO2    = SUM(CASE AbnormalPoint WHEN  2  THEN 1 ELSE 0 END ),
         @APO3    = SUM(CASE AbnormalPoint WHEN  3  THEN 1 ELSE 0 END ),        
         @APO4    = SUM(CASE AbnormalPoint WHEN  4  THEN 1 ELSE 0 END ),        
         @ATY2    = SUM(CASE AbnormalType  WHEN  2  THEN 1 ELSE 0 END ),
         @ATY3    = SUM(CASE AbnormalType  WHEN  3  THEN 1 ELSE 0 END ),
         @PlanQty = SUM(1)
    FROM
         MFG_WIP_Data_Abnormal AB
        ,MFG_WO_List WO
    WHERE
           AB.WorkOrderNumber     = WO.ErpWorkOrderNumber
       AND AB.WorkOrderVersion    = WO.MesWorkOrderVersion
       AND AB.AbnormalType > 1
       AND WO.ID = @WoId

--此处需求没有重新定义, 也许[需要重写]
    IF @APO3 > 0 OR @ATY2 > 0 
       SET @StartPoint = '0';
    ELSE 
       IF @APO1 > 0
          SET @StartPoint = '1';
       ELSE
          SET @StartPoint = '2';

    --(1).设置当前订单已创建补单标记
    UPDATE MFG_WO_List 
    SET 
        MesSubPlanFlag = 1 
    WHERE 
        ID = @WoId;

    --(2).设置当前订单的下线记录为已经创建补单标记
    UPDATE AB
    SET 
        SubPlanStatus = 1
    FROM 
         MFG_WIP_Data_Abnormal AB
        ,MFG_WO_List WO
    WHERE 
          AB.WorkOrderNumber  = WO.ErpWorkOrderNumber
      AND AB.WorkOrderVersion = WO.MesWorkOrderVersion
      AND WO.ID               = @WoId;

    --(3).设置新的补单版本
    SET @WorkOrderVersion = @WorkOrderVersion + 1

    --(4).插入新的订单记录到表:Mfg_WO_List
    INSERT INTO Mfg_WO_List
                   ([MesStartPoint], [MesInturnNumber] ,[MesWorkOrderType], [MesWorkOrderVersion], [MesPlanQty] , [MesCreateUser], [MesPlanStartTime] ,[MesPlanFinishTime] ,                                     [MesCostTime] ,              [ErpWorkOrderNumber] ,[ErpGoodsCode] ,[ErpGoodsDsca] ,[ErpPlanQty] ,[ErpPlanCreateTime] ,[ErpPlanStartTime] ,[ErpPlanFinishTime] ,[ErpPlanReleaseTime] ,[ErpWorkGroup] ,[ErpOrderType] ,[ErpOrderStatus] ,[ErpOBJNR] ,[ErpZTYPE], [MesUnitCostTime], [MesCustomerID], [MesOrderComment])
    SELECT          @StartPoint,     -1 ,                1 ,                @WorkOrderVersion ,    @PlanQty ,     @UserName,        GETDATE() ,         DATEADD(SECOND, MesUnitCostTime * @PlanQty, GETDATE()) , MesUnitCostTime * @PlanQty , [ErpWorkOrderNumber] ,[ErpGoodsCode] ,[ErpGoodsDsca] ,[ErpPlanQty] ,[ErpPlanCreateTime] ,[ErpPlanStartTime] ,[ErpPlanFinishTime] ,[ErpPlanReleaseTime] ,[ErpWorkGroup] ,[ErpOrderType] ,[ErpOrderStatus] ,[ErpOBJNR] ,[ErpZTYPE], [MesUnitCostTime], [MesCustomerID], [MesOrderComment]
    FROM Mfg_WO_List
    WHERE ID = @WoId;

    --(5).更新订单的生产排程顺序.
    UPDATE MFG_WO_List 
    SET MesInturnNumber = SCOPE_IDENTITY()
    WHERE ID = SCOPE_IDENTITY();
GO

--取得某个指定的订单的详细信息
ALTER PROCEDURE  [dbo].[usp_Mfg_Wo_List_one_detail]
     @WOID               AS INT                  --Mfg_WO_LIST.ID
AS
    SELECT
         WO.ID
        ,WO.ErpWorkOrderNumber WorkOrderNumber
        ,WO.ErpGoodsCode GoodsCode
        ,WO.ErpGoodsDsca GoodsDsca
        ,WO.MesPlanQty PlanQty
        ,FORMAT(WO.MesPlanStartTime, 'yyyy-MM-dd hh:mm')  PlanStartTime
        ,FORMAT(WO.MesPlanFinishTime,'yyyy-MM-dd hh:mm')  PlanFinishTime
        ,WO.MesCostTime      CostTime
        ,WO.MesUnitCostTime  UnitCostTime
        ,WO.MesWorkOrderType WorkOrderType
        ,WO.MesCustomerID    CustomerID
        ,WO.MesOrderComment  OrderComment
        ,MesDiscardQty1 + MesDiscardQty2 + MesDiscardQty3 + MesDiscardQty4  DiscardQty
        ,MesLeftQty1         LeftQty1
        ,MesLeftQty2         LeftQty2
        ,MesLeftQty3         LeftQty3
        ,MesLeftQty4         LeftQty4
    FROM MFG_WO_List WO
    WHERE
        WO.ID = @WOID
GO

--更新订单的报废, 未完工数量
ALTER PROCEDURE  [dbo].[usp_Mfg_Wo_List_ABN_Qty_Update]
      @WorkOrderNumber        AS VARCHAR(50)
     ,@WorkOrderVersion       AS INT
AS
    DECLARE @ABN TABLE(
        WorkOrderNumber  VARCHAR(50),
        WorkOrderVersion INT,
        LeftQty1         INT,
        LeftQty2         INT,
        LeftQty3         INT,
        LeftQty4         INT,
        DiscardQty1      INT,
        DiscardQty2      INT,
        DiscardQty3      INT,
        DiscardQty4      INT
    )
    INSERT INTO @ABN
    EXEC usp_Mfg_Wip_Data_Abnormal_SummayQty @WorkOrderNumber, @WorkOrderVersion

    UPDATE Mfg_WO_List 
    SET 
         Mfg_WO_List.MesLeftQty1    = ABN.LeftQty1
        ,Mfg_WO_List.MesLeftQty2    = ABN.LeftQty2
        ,Mfg_WO_List.MesLeftQty3    = ABN.LeftQty3
        ,Mfg_WO_List.MesLeftQty4    = ABN.LeftQty4
        ,Mfg_WO_List.MesDiscardQty1 = ABN.DiscardQty1
        ,Mfg_WO_List.MesDiscardQty2 = ABN.DiscardQty2
        ,Mfg_WO_List.MesDiscardQty3 = ABN.DiscardQty3
        ,Mfg_WO_List.MesDiscardQty4 = ABN.DiscardQty4
    FROM @ABN ABN
    WHERE 
         Mfg_WO_List.ErpWorkOrderNumber  = ABN.WorkOrderNumber
     AND Mfg_WO_List.MesWorkOrderVersion = ABN.WorkOrderVersion
GO

--取得下线记录清单
ALTER PROCEDURE  [dbo].[usp_Mfg_Wip_Data_Abnormal]
      @RFID               AS NVARCHAR (50)
     ,@WorkOrderNumber    AS VARCHAR  (50)
     ,@GoodsCode          AS VARCHAR  (50)
     ,@AbnormalPoint      AS NVARCHAR (50)
     ,@AbnormalType       AS VARCHAR  (10)
     ,@FromTime           AS VARCHAR  (50)
     ,@ToTime             AS VARCHAR  (50)
AS
    IF @FromTime = ''
    BEGIN
        SET @FromTime = FORMAT( GETDATE(), 'yyyy-MM-dd', 'en-US' ) + ' 00:00:00';
    END
    
    IF @ToTime = ''
    BEGIN
        SET @ToTime   = FORMAT( GETDATE(), 'yyyy-MM-dd', 'en-US' ) + ' 23:59:59';
    END
    
    IF @AbnormalType = ''
    BEGIN
        SET @AbnormalType = '-1'
    END
    
    SELECT
         AB.ID                 ID
        ,AB.RFID               RFID
        ,AB.AbnormalPoint      AbnormalPoint
        ,AP.DisplayValue       AbnormalDisplayValue
        ,AB.AbnormalType       AbnormalType
        ,AB.AbnormalTime       AbnormalTime
        ,AB.AbnormalUser       AbnormalUser
        ,AB.SubPlanStatus      SubPlanStatus
        ,WO.ErpGoodsCode       GoodsCode
        ,WO.ErpWorkOrderNumber WorkOrderNumber
    FROM
         MFG_WIP_Data_Abnormal AB
        ,MFG_WO_List WO
        ,MFG_WIP_Data_Abnormal_Point AP
    WHERE
           AB.WorkOrderNumber     = WO.ErpWorkOrderNumber
       AND AB.WorkOrderVersion    = WO.MesWorkOrderVersion
       AND AB.AbnormalPoint       = AP.ID
       AND (WO.ErpWorkOrderNumber = @WorkOrderNumber             OR @WorkOrderNumber = '')
       AND (WO.ErpGoodsCode       = @GoodsCode                   OR @GoodsCode       = '')
       AND (AB.RFID               = @RFID                        OR @RFID            = '')
       AND (AB.AbnormalPoint      = @AbnormalPoint               OR @AbnormalPoint   = '')
       AND (AB.AbnormalType       = CONVERT(INT, @AbnormalType)  OR @AbnormalType    = '-1')
       AND (AB.AbnormalTime      >= CONVERT(DATETIME, @FromTime))
       AND (AB.AbnormalTime      <= CONVERT(DATETIME, @ToTime)  )
    ORDER BY 
       AbnormalTime DESC

  -- UNION ALL
  -- SELECT 1, 'RFIDVALUE1' , '下线点1', 1, GETDATE(), '王大拿', 'GOODSCODE', '2017060631'
  -- UNION ALL
  -- SELECT 2, 'RFIDVALUE2' , '下线点2', 2, GETDATE(), '马大帅', 'GOODSCODE', '2017060641'

GO

--取得下线产品用料清单
ALTER PROCEDURE  [dbo].[usp_Mfg_Wip_Data_Abnormal_Mtl]
      @AbId               AS NVARCHAR (50)
AS
    
    SELECT
         ID
        ,AbnormalID
        ,ProcessCode
        ,ItemNumber
        ,ItemDsca
        ,UOM
        ,LeftQty
        ,RequireQty
    FROM
         MFG_WIP_Data_Abnormal_MTL MTL
    WHERE
         AbnormalID = @AbId
GO

-- 根据下线点取出最近一次的RFID信息记录值, 已经[重写完成]
-- 取得最后近次的正常生产的RFID所代表工单等信息
ALTER PROCEDURE  [dbo].[usp_Mfg_Wip_Data_Rfid_getLast]
      @RFID               AS NVARCHAR (50) OUTPUT
     ,@WorkOrderNumber    AS VARCHAR  (50) OUTPUT
     ,@WorkOrderVersion   AS INT           OUTPUT
     ,@GoodsCode          AS VARCHAR  (50) OUTPUT
     ,@ProcessCode        AS VARCHAR  (50) OUTPUT
     ,@AbnormalPoint      AS INT           
AS
    --取得下线点对应的RFID读头   
    DECLARE @ReaderCode AS VARCHAR(50);
    SELECT 
         @ReaderCode  = ReaderCode
        ,@ProcessCode = ProcessCode
    FROM Mes_RFID_Reader_List
    WHERE AbnormalPoint = @AbnormalPoint;
    
    --找到最后一条读头读取的信息
    DECLARE @MAXT DATETIME;
    SELECT
        @MAXT = MAX(InTime)
    FROM Mes_RFID_RecordHistory
    WHERE
         AreaCode = @ReaderCode;
     
    --获取RFID信息   
    SELECT 
        @RFID = MesCode 
    FROM 
        Mes_RFID_RecordHistory
    WHERE
        inTime   = @MAXT
    AND AreaCode = @ReaderCode

    --截取订单号码:
    SET @WorkOrderNumber = LEFT(@RFID, 8);

    SELECT
         @GoodsCode        = ErpGoodsCode
        ,@WorkOrderNumber  = ErpWorkOrderNumber 
        ,@WorkOrderVersion = MesWorkOrderVersion 
    FROM
         MFG_WO_List
    WHERE
          @WorkOrderNumber  = ErpWorkOrderNumber
      AND MesStatus = 2;
GO

--取得下线记录详细信息
ALTER PROCEDURE  [dbo].[usp_Mfg_Wip_Data_Abnormal_Detail]
      @AbId               AS VARCHAR  (50)
     ,@AbnormalPoint      AS INT
     ,@UserName           AS NVARCHAR (50)
AS
    IF @AbId <> '0'  --表示不是新增的下线, 是取得已经下线的下线项信息.
    BEGIN
        SELECT
             AB.ID                 ID
            ,WO.ErpGoodsCode       GoodsCode
            ,WO.ErpWorkOrderNumber WorkOrderNumber
            ,AB.RFID               RFID
            ,AB.AbnormalPoint      AbnormalPoint
            ,AB.AbnormalProduct    AbnormalProduct
            ,AB.AbnormalType       AbnormalType
            ,AB.AbnormalTime       AbnormalTime
            ,AB.AbnormalUser       AbnormalUser
        FROM
             MFG_WIP_Data_Abnormal AB
            ,MFG_WO_List WO
        WHERE
               AB.WorkOrderNumber  = WO.ErpWorkOrderNumber
           AND AB.WorkOrderVersion = WO.MesWorkOrderVersion
           AND AB.ID               = CONVERT(INT, @AbID)
    END
    ELSE
    BEGIN
        DECLARE @WorkOrderNumber  VARCHAR(50);
        DECLARE @WorkOrderVersion INT;
        DECLARE @GoodsCode        VARCHAR(50);
        DECLARE @ProcessCode      INT;
        DECLARE @RFID             VARCHAR(50);
    
        EXEC usp_Mfg_Wip_Data_Rfid_getLast @RFID OUTPUT, @WorkOrderNumber OUTPUT, @WorkOrderVersion OUTPUT, @GoodsCode OUTPUT, @ProcessCode OUTPUT, @AbnormalPoint
    
        SELECT
             0                 ID
            ,@RFID             RFID
            ,@AbnormalPoint    AbnormalPoint
            ,0                 AbnormalProduct
            ,1                 AbnormalType
            ,GETDATE()         AbnormalTime
            ,@UserName         AbnormalUser
            ,@GoodsCode        GoodsCode
            ,@WorkOrderNumber  WorkOrderNumber
    END
GO

--新建下线记录信息
ALTER PROCEDURE  [dbo].[usp_Mfg_Wip_Data_Abnormal_Add]
     @AbId               AS INT
    ,@AbnormalType       AS VARCHAR  (5)
    ,@AbnormalTime       AS VARCHAR  (50)
    ,@AbnormalUser       AS NVARCHAR (50)
    ,@AbnormalPoint      AS INT
    ,@AbnormalProduct    AS INT
    ,@UpdateUser         AS NVARCHAR (50)
    ,@AbIdOperate        AS INT           OUTPUT --返回刚刚产生的新的ID值, 便于后期录入下线原因
    ,@CatchError         AS INT           OUTPUT --系统判断用户操作异常的数量
    ,@RtnMsg             AS NVARCHAR(100) OUTPUT --返回状态
AS
    SET @CatchError = 0
    SET @RtnMsg     = ''

    DECLARE @WorkOrderNumber  VARCHAR(50);
    DECLARE @WorkOrderVersion INT;
    DECLARE @GoodsCode        VARCHAR(50);
    DECLARE @ProcessCode      INT;
    DECLARE @RFID             VARCHAR(50);
    
    EXEC usp_Mfg_Wip_Data_Rfid_getLast @RFID OUTPUT, @WorkOrderNumber OUTPUT, @WorkOrderVersion OUTPUT, @GoodsCode OUTPUT, @ProcessCode OUTPUT, @AbnormalPoint
    
    --检查获取的订单是否有效
    IF @WorkOrderVersion IS NULL
    BEGIN
        SET @CatchError = 1;
        SET @RtnMsg = '系统未发现有此订单, 请您仔细核对!';
        RETURN;
    END   
     
    --检查在本下线工位是否已经存在了此记录, 防止重复录入.
    DECLARE @ExistCount   INT;
    SELECT 
         @ExistCount = COUNT(1) 
    FROM 
    MFG_WIP_Data_Abnormal
    WHERE 
          RFID           = @RFID
      AND AbnormalPoint  = @AbnormalPoint
      AND RepairStatus  <> 2 --表示待修或者补修中的已经存在, 如果存在补修记录并且已经维修完成过的, 则可以进行再次下线
                             
    IF @ExistCount > 0 
    BEGIN
        SET @CatchError = 1;
        SET @RtnMsg = '系统发现在此下线点已经存在此号码:''' + @RFID + '''的下线, 并且其当下尚未完成补修!';
        RETURN;
    END

    --此处应该加入检查订单是否已经产生了补单状态. 
    --考虑到实际情况觉得没有必要加入此种判断. 也许需要去除此种判断, 此处目前处理的比较全面, 因此不必[需要重写].
    IF ( SELECT MesSubPlanFlag 
         FROM MFG_WO_List 
         WHERE 
             ErpWorkOrderNumber  = @WorkOrderNumber 
         AND MesWorkOrderVersion = @WorkOrderVersion
        ) > 0
    BEGIN
        SET @CatchError = 1;
        SET @RtnMsg =  '系统已经据此下线记录生成了下线补单, 因此不可以新增产品下线记录!<br>'
                     + '请联系排程人员把据此订单生成的下线补单删除后继续操作!';
        RETURN;
    END

    --插入新的待补修记录
    INSERT INTO 
    MFG_WIP_Data_Abnormal
           ( RFID , AbnormalPoint , AbnormalType , AbnormalTime , AbnormalUser , AbnormalProduct , WorkOrderNumber , WorkOrderVersion , UpdateUser)
    VALUES (@RFID ,@AbnormalPoint ,@AbnormalType ,@AbnormalTime ,@AbnormalUser ,@AbnormalProduct ,@WorkOrderNumber ,@WorkOrderVersion ,@UpdateUser);

    --更新订单的报废, 未完工数量
    EXEC [usp_Mfg_Wo_List_ABN_Qty_Update] @WorkOrderNumber, @WorkOrderVersion;

    --此处相同号码多次补修, 重复计算额外领料数量, 
    --日后根据生产使用实践, 可以根据实际情况把此条件去掉或保留.
    --目前来看, 此处的处理不必[需要重写]
  --IF @ExistCount = 0 
    BEGIN
        SELECT @AbId = SCOPE_IDENTITY();
        SELECT @AbIdOperate = @AbId;
        EXEC usp_Mfg_Wip_Data_Abnormal_Mtl_Insert @AbID
    END
GO

--更新下线记录信息
ALTER PROCEDURE  [dbo].[usp_Mfg_Wip_Data_Abnormal_Edit]
     @AbId               AS INT
    ,@AbnormalType       AS VARCHAR  (5)
    ,@AbnormalTime       AS VARCHAR  (50)
    ,@AbnormalUser       AS NVARCHAR (50)
    ,@AbnormalPoint      AS INT
    ,@AbnormalProduct    AS INT
    ,@UpdateUser         AS NVARCHAR (50)
    ,@AbIdOperate        AS INT           OUTPUT --返回刚刚操作的Abnormal ID
    ,@CatchError         AS INT           OUTPUT --系统判断用户操作异常的数量
    ,@RtnMsg             AS NVARCHAR(100) OUTPUT --返回状态
AS
    SET @CatchError = 0
    SET @RtnMsg     = ''

    SET @AbIdOperate = @AbId;  --词句是为了和ADD新的下线记录具有相同的操作语句而采取的数据回传.

    DECLARE @AbIdCount INT;
    SELECT @AbIdCount = COUNT(1) 
    FROM
        MFG_WIP_Data_Abnormal
    WHERE
         ID = @AbId

    --检查传入的AbId是否有效
    IF @AbIdCount = 0 
    BEGIN
        SET @CatchError = 1;
        SET @RtnMsg = '系统未发现此可以更新的数据!'; 
        RETURN;
    END 

    --已经完成了补修动作, 其就不应该可以修改了.
    IF (SELECT MAX(RepairStatus) FROM MFG_WIP_Data_Abnormal WHERE ID = @AbId) > 0
    BEGIN
        SET @CatchError = 1;
        SET @RtnMsg = '此下线记录已经进行了补修操作, 因此不允许进行修改!';
        RETURN;
    END
    
    --已经生成下线补单了, 其就不应该可以更改了.
    IF (SELECT MAX(SubPlanStatus) FROM MFG_WIP_Data_Abnormal WHERE ID = @AbId) > 0
    BEGIN
        SET @CatchError = 1;
        SET @RtnMsg = '系统已经据此下线记录生成了下线补单, 因此不可以修改!';
        RETURN;
    END

    --更新数据记录
    UPDATE MFG_WIP_Data_Abnormal
    SET
         AbnormalProduct= @AbnormalProduct
        ,AbnormalType   = @AbnormalType
        ,AbnormalTime   = @AbnormalTime
        ,AbnormalUser   = @AbnormalUser
        ,UpdateUser     = @Updateuser
        ,UpdateTime     = GETDATE()
    WHERE
         ID = @AbId
    
    IF @@ROWCOUNT > 0  --说明最后的更新语句更新了至少一条记录.
    BEGIN 

        DELETE FROM MFG_WIP_Data_Abnormal_MTL WHERE AbnormalID = @AbId;
        EXEC usp_Mfg_Wip_Data_Abnormal_Mtl_Insert @AbId;

        --取得下线记录的对应工单
        DECLARE @WorkOrderNumber    VARCHAR(50);
        DECLARE @WorkOrderVersion   INT;
        SELECT 
             @WorkOrderNumber  = WorkOrderNumber  
            ,@WorkOrderVersion = WorkOrderVersion
        FROM MFG_WIP_Data_Abnormal 
        WHERE ID = @AbId;

        --更新订单的报废, 未完工数量
        EXEC [usp_Mfg_Wo_List_ABN_Qty_Update] @WorkOrderNumber, @WorkOrderVersion;
    END
GO

--更新下线产品计件物料信息
ALTER PROCEDURE  [dbo].[usp_Mfg_Wip_Data_Abnormal_Mtl_Edit]
     @ID                 AS VARCHAR  (50)
    ,@LeftQty            AS VARCHAR  (50)
    ,@RequireQty         AS VARCHAR  (5)
    ,@UpdateUser         AS NVARCHAR (50)
    ,@CatchError         AS INT           OUTPUT --系统判断用户操作异常的数量
    ,@RtnMsg             AS NVARCHAR(100) OUTPUT --返回状态
AS
    SET @CatchError = 0
    SET @RtnMsg     = ''

    IF (
        SELECT MAX(ABN.SubPlanStatus)
        FROM 
             MFG_WIP_Data_Abnormal     ABN
            ,MFG_WIP_Data_Abnormal_MTL MTL
        WHERE 
             ABN.ID = MTL.AbnormalID
         AND MTL.ID = @ID
    ) > 0 
    BEGIN
        SET @CatchError = @CatchError + 1
        SET @RtnMsg     = '已经据此记录生成了下线补单, 因此其用料不可以进行修改了!'
        RETURN
    END

    --更新数据记录
    UPDATE MFG_WIP_Data_Abnormal_MTL
    SET
         LeftQty        = @LeftQty
        ,RequireQty     = @RequireQty
        ,UpdateUser     = @Updateuser
        ,UpdateTime     = GETDATE()
    WHERE
         ID = @ID
GO

--插入产品下线需求的额外物料记录
--其只被下线记录的新增和修改两个操作调用.
--此存储过程没有用户的界面直接调用的机会, 因此就不做异常判定操作了.
--此存储过程已经[重新完成]
ALTER PROCEDURE  [dbo].[usp_Mfg_Wip_Data_Abnormal_Mtl_Insert]
     @AbId               AS VARCHAR  (50)
AS
    --需要确定从原用料表中确定从何处工序代码开始计算额外申领物料
    DECLARE @FinalProcessCode   VARCHAR(50);
    DECLARE @FinalInturnNumber  INT;
    DECLARE @AbnormalPoint      INT;
    DECLARE @AbnormalProduct    INT;
    DECLARE @AbnormalType       INT;

    SELECT 
         @AbnormalPoint   = AbnormalPoint
        ,@AbnormalProduct = AbnormalProduct
        ,@AbnormalType    = AbnormalType
    FROM 
        MFG_WIP_Data_Abnormal 
    WHERE 
        ID = @AbId;

    --因为涉及到工序路线分支的组合问题, 此处已经使用了计算下线范围定义表:MFG_WIP_Data_Abnormal_Process
    --只有 "报废", "未完工" 的下线才需要进行额外物料申领操作, 补修的下线: AbnormalType = 1 不需要额外申请物料
    IF @AbnormalType <> 1
    BEGIN
        INSERT INTO MFG_WIP_Data_Abnormal_MTL 
              ( AbnormalID,        ProcessCode,                                  ItemNumber,     ItemDsca,     UOM,     UpdateUser, LeftQty, RequireQty)
        SELECT ABN.ID AbnormalID,  ISNULL(MUB.ProcessCode, '1010') ProcessCode , MTL.ItemNumber, MTL.ItemDsca, MTL.UOM, ABN.UpdateUser, 
        CASE 
            WHEN ABP.ID IS NULL THEN
                MTL.Qty/WOL.MesPlanQty * ISNULL(MUB.MubPercent, 100.0) / 100.0
            ELSE
                0
        END AS LeftQty, 
        CASE 
            WHEN ABP.ID IS NULL THEN 
                0
            ELSE 
                MTL.Qty/WOL.MesPlanQty * ISNULL(MUB.MubPercent, 100.0) / 100.0
        END AS RequireQty
        FROM 
                   MFG_WO_MTL_List               MTL
        INNER JOIN MFG_WO_List                   WOL ON WOL.ErpWorkOrderNumber = MTL.WorkOrderNumber AND MTL.WorkOrderVersion    = 0
        INNER JOIN MFG_WIP_Data_Abnormal         ABN ON WOL.ErpWorkOrderNumber = ABN.WorkOrderNumber AND WOL.MesWorkOrderVersion = 0 
        LEFT  JOIN Mes_Mub_List                  MUB ON MUB.GoodsCode          = WOL.ErpGoodsCode    AND MTL.ItemNumber          = MUB.ItemNumber 
        LEFT  JOIN MFG_WIP_Data_Abnormal_Process ABP ON ABP.abProductId        = ABN.AbnormalProduct AND ABP.ProcessCode         = MUB.ProcessCode
        WHERE 
        --此处逻辑为: 应该根据"根订单"(WorkOrderVersion = 0)计算产品用料. 
        --因为如果根据子订单的话，其用料数据(额外领料单)可能是用户调整过的.           
        1=1
        AND ABN.ID                = @AbId
        AND UPPER(MTL.Backflush) <> 'X' 
        AND UPPER(MTL.[BULK]   ) <> 'X' 
        AND UPPER(MTL.Phantom  ) <> 'X'  --需要三者同时都不许为X的状态才是我们需要考虑的计件物料. 2017-06-13 17:16
    END
GO

--取得某个指定的订单的所对应的下线物料清单的汇总
ALTER PROCEDURE  [dbo].[usp_Mfg_Wip_Data_Abnormal_Mtl_List_Summary]
     @WOID               AS INT                  --Mfg_WO_LIST.ID
AS
    SELECT
         MTL.ProcessCode     ProcessCode
        ,MTL.ItemNumber      ItemNumber
        ,MTL.ItemDsca        ItemDsca
        ,MTL.UOM             UOM
        ,SUM(MTL.LeftQty)    LeftQty
        ,SUM(MTL.RequireQty) RequireQty
    FROM
         MFG_WIP_Data_Abnormal AB
        ,MFG_WIP_Data_Abnormal_MTL MTL
        ,MFG_WO_List WO
   WHERE
            WO.ID = @WOID
        AND AB.ID = MTL.AbnormalID
        AND AB.WorkOrderNumber  = WO.ErpWorkOrderNumber
        AND AB.WorkOrderVersion = WO.MesWorkOrderVersion
    GROUP BY
        MTL.ProcessCode,
        MTL.ItemNumber,
        MTL.ItemDsca,
        MTL.UOM
GO

--生产排程:订单顺序调整
ALTER PROCEDURE  [dbo].[usp_Mfg_Wo_List_Adjust_Inturn]
     @WOID               AS INT                  --Mfg_WO_LIST更改ID
    ,@NBID               AS INT                  --Mfg_WO_LIST相邻ID
    ,@ADJDirection       AS VARCHAR (50)         --调整顺序的方向: PREV:向前调整, NEXT:向后调整
    ,@CatchError         AS INT           OUTPUT --系统判断用户操作异常的数量
    ,@RtnMsg             AS NVARCHAR(100) OUTPUT --返回状态
AS
    SET @CatchError = 0
    SET @RtnMsg     = ''

    IF @NBID = 0
    BEGIN
        IF @ADJDirection='PREV'
        BEGIN
            SET @CatchError = @CatchError + 1
            SET @RtnMsg     = '不能继续向前调整了, 已经到开头了!!'
            RETURN
        END

        IF @ADJDirection='NEXT'
        BEGIN
            SET @CatchError = @CatchError + 1
            SET @RtnMsg     = '不能继续向后调整了, 已经到末尾了!!'
            RETURN
        END
    END
    ELSE
    BEGIN
        IF (SELECT COUNT(1) FROM MFG_WO_List WHERE ID=@WOID) = 0
        BEGIN
            SET @CatchError = @CatchError + 1
            SET @RtnMsg     = '您要调整的记录并不存在, 请刷新后重试! [WOID:' + CONVERT(VARCHAR(10), @WOID) + ']!'
            RETURN
        END
        IF (SELECT COUNT(1) FROM MFG_WO_List WHERE ID=@NBID) = 0
        BEGIN
            SET @CatchError = @CatchError + 1
            SET @RtnMsg     = '您要调整的相邻记录已经不存在了, 请刷新后重试! [NBID:' + CONVERT(VARCHAR(10), @NBID) + ']'
            RETURN
        END
    END

    DECLARE @InturnNumber    INT;
    DECLARE @NeighbourNumber INT;
    DECLARE @ExchangeNumber  INT;
    DECLARE @WOMesStatus     INT;
    DECLARE @NBMesStatus     INT;

    --此处也许还有一大堆的判断条件.
    --usp_Mfg_Wo_List_Get_InturnRange @FirstLine, @LastLine;

    SELECT @NeighbourNumber = MesInturnNumber, @NBMesStatus = MesStatus FROM Mfg_Wo_List WHERE ID = @NBID
    SELECT @InturnNumber    = MesInturnNumber, @WOMesStatus = MesStatus FROM Mfg_Wo_List WHERE ID = @WOID

    IF @NBMesStatus <> 0
    BEGIN
        SET @CatchError = @CatchError + 1
        SET @RtnMsg     = '您要与其交换的相邻记录已经不可以移动了, 请核对! [NBID:' + CONVERT(VARCHAR(10), @NBID) + ']'
        RETURN
    END

    IF @WOMesStatus <> 0
    BEGIN
        SET @CatchError = @CatchError + 1
        SET @RtnMsg     = '您要调整的记录当下已经不可以移动了, 请核对! [WOID:' + CONVERT(VARCHAR(10), @WOID) + ']'
        RETURN
    END

    --顺序号切换
    SELECT @ExchangeNumber = @InturnNumber,
           @InturnNumber   = @NeighbourNumber,
           @NeighbourNumber= @ExchangeNumber;

    BEGIN TRANSACTION
        UPDATE MFG_WO_List SET MesInturnNumber = @InturnNumber    WHERE ID = @WOID;
        UPDATE MFG_WO_List SET MesInturnNumber = @NeighbourNumber WHERE ID = @NBID;
    COMMIT TRANSACTION
GO

--生产排程:订单修改
ALTER PROCEDURE  [dbo].[usp_Mfg_Wo_List_Edit]
     @WOID               AS INT                  --Mfg_WO_LIST更改ID
    ,@UnitCostTime       AS INT
    ,@CostTime           AS INT
    ,@PlanStartTime      AS DATETIME
    ,@PlanFinishTime     AS DATETIME
    ,@CustomerID         AS INT
    ,@OrderComment       AS NVARCHAR(150)
    ,@CatchError         AS INT           OUTPUT --系统判断用户操作异常的数量
    ,@RtnMsg             AS NVARCHAR(100) OUTPUT --返回状态
AS
    SET @CatchError = 0
    SET @RtnMsg     = ''

    IF (SELECT COUNT(1) FROM MFG_WO_List WHERE ID=@WOID) = 0
    BEGIN
        SET @CatchError = @CatchError + 1
        SET @RtnMsg     = '您要调整的记录并不存在, 请刷新后重试! [WOID:' + CONVERT(VARCHAR(10), @WOID) + ']!'
        RETURN
    END

    IF (SELECT MAX(MesStatus) FROM MFG_WO_List WHERE ID=@WOID) <> 0
    BEGIN
        SET @CatchError = @CatchError + 1
        SET @RtnMsg     = '您要修改的订单当前状态不允许变动, 请核对订单状态! [WOID:' + CONVERT(VARCHAR(10), @WOID) + ']!'
        RETURN
    END

    BEGIN TRANSACTION
        UPDATE MFG_WO_List SET
             MesUnitCostTime   = @UnitCostTime
            ,MesCostTime       = @CostTime
            ,MesPlanStartTime  = @PlanStartTime
            ,MesPlanFinishTime = @PlanFinishTime
            ,MesCustomerID     = @CustomerID
            ,MesOrderComment   = @OrderComment
        WHERE ID = @WOID;
    COMMIT TRANSACTION
GO

--生产排程:订单删除
ALTER PROCEDURE  [dbo].[usp_Mfg_Wo_List_Delete]
     @WOID               AS INT                  --Mfg_WO_LIST更改ID
    ,@CatchError         AS INT           OUTPUT --系统判断用户操作异常的数量
    ,@RtnMsg             AS NVARCHAR(100) OUTPUT --返回状态
AS
    SET @CatchError = 0
    SET @RtnMsg     = ''

    IF (SELECT COUNT(1) FROM MFG_WO_List WHERE ID=@WOID) = 0
    BEGIN
        SET @CatchError = @CatchError + 1
        SET @RtnMsg     = '您要调整的记录并不存在, 请刷新后重试! [WOID:' + CONVERT(VARCHAR(10), @WOID) + ']!'
        RETURN
    END

    IF (SELECT MAX(MesStatus) FROM MFG_WO_List WHERE ID=@WOID) <> 0
    BEGIN
        SET @CatchError = @CatchError + 1
        SET @RtnMsg     = '您要删除的订单当前状态不允许删除, 请核对后重试! [WOID:' + CONVERT(VARCHAR(10), @WOID) + ']!'
        RETURN
    END

    IF (SELECT MIN(MesWorkOrderType) FROM MFG_WO_List WHERE ID=@WOID) = 0
    BEGIN
        SET @CatchError = @CatchError + 1
        SET @RtnMsg     = '您要删除的订单不属于下线补单, 因此不允许删除! [WOID:' + CONVERT(VARCHAR(10), @WOID) + ']!'
        RETURN
    END

    BEGIN TRANSACTION
         
    --(1).去除当前订单的主订单已创建补单标记
        UPDATE OWO
        SET 
            MesSubPlanFlag = 0
        FROM 
             MFG_WO_List DWO  --当前订单(下线补单)
            ,MFG_WO_List OWO  --当前订单的主订单
        WHERE 
              DWO.ErpWorkOrderNumber  = OWO.ErpWorkOrderNumber
          AND DWO.MesWorkOrderVersion = OWO.MesWorkOrderVersion + 1
          AND DWO.ID                  = @WoId;

    --(2).去除当前订单的下线记录的已创建补单标记
        UPDATE AB
        SET 
            SubPlanStatus = 0
        FROM 
             MFG_WIP_Data_Abnormal AB --当前订单的主订单的下线记录
            ,MFG_WO_List           WO --当前订单(下线补单)
        WHERE 
              WO.ErpWorkOrderNumber  = AB.WorkOrderNumber  
          AND WO.MesWorkOrderVersion = AB.WorkOrderVersion + 1
          AND WO.ID                  = @WoId;
            
    --(3).删除当前订单的用料清单
        DELETE MTL
        FROM MFG_WO_MTL_List MTL
        INNER JOIN MFG_WO_LIST WO ON
               MTL.WorkOrderNumber  = WO.ErpWorkOrderNumber
           AND MTL.WorkOrderVersion = WO.MesWorkOrderVersion
        WHERE
             WO.ID = @WOID;

    --(4).删除当前订单
        DELETE FROM MFG_WO_List WHERE ID = @WOID;
    COMMIT TRANSACTION
GO

--生产排程:订单完工报工
ALTER PROCEDURE  [dbo].[usp_Mfg_Wo_List_Roc_Edit]
     @WOID               AS INT                  --Mfg_WO_LIST更改ID
    ,@ROCQTY             AS VARCHAR(50)          --报完工数量
    ,@UserName           AS NVARCHAR(50)         --报完工人员
    ,@CatchError         AS INT           OUTPUT --系统判断用户操作异常的数量
    ,@RtnMsg             AS NVARCHAR(100) OUTPUT --返回状态
AS
    SET @CatchError = 0
    SET @RtnMsg     = ''

    IF (SELECT COUNT(1) FROM MFG_WO_List WHERE ID=@WOID) = 0
    BEGIN
        SET @CatchError = @CatchError + 1
        SET @RtnMsg     = '您要报完工的订单并不存在, 请刷新后重试! [WOID:' + CONVERT(VARCHAR(10), @WOID) + ']!'
        RETURN
    END

    DECLARE @MesStatus AS INT;
    SELECT @MesStatus = MAX(MesStatus) FROM MFG_WO_List WHERE ID=@WOID;

    IF @MesStatus <> 3 AND @MesStatus <> 2
    BEGIN
        SET @CatchError = @CatchError + 1
        SET @RtnMsg     = '您要修改的订单当前状态不是:已完成或生产进行中, 请核对订单状态! [WOID:' + CONVERT(VARCHAR(10), @WOID) + ']!'
        RETURN
    END


    IF ((SELECT ISNULL(SUM( FinishQty ), 0)
        FROM ERP_WO_REPORT_COMPLETE
        WHERE WOID = @WOID ) + CONVERT(INT, @ROCQty)) > (SELECT MesFinishQty FROM MFG_WO_List WHERE ID = @WOID)
    BEGIN
        SET @CatchError = @CatchError + 1
        SET @RtnMsg     = '您当下提交的报工数量已经超过了完工数量, 请核对! [WOID:' + CONVERT(VARCHAR(10), @WOID) + ']!'
        RETURN
    END
    
    BEGIN TRANSACTION
        INSERT INTO ERP_WO_REPORT_COMPLETE 
               (WOID, AUFNR,                       MATNR,                    MAKTX,        GAMNG,      FinishQty,             MesCreateUser, MesCreateTime, MesModifyTime, ErpCfmStatus, MesCfmStatus)
        SELECT  ID,  '0000' + ErpWorkOrderNumber, '00000000' + ErpGoodsCode, ErpGoodsDsca, ErpPlanQty, CONVERT(INT, @ROCQTY), @UserName,     GETDATE(),     GETDATE(),     0,            0 
        FROM MFG_WO_List
        WHERE ID = @WOID

        UPDATE MFG_WO_List SET
             Mes2ErpCfmQty = Mes2ErpCfmQty + CONVERT(INT, @ROCQty)
            ,Mes2ErpCfmStatus = 0
        WHERE ID = @WOID;

        --在全局状态表中加入更新到SAP的标志
        UPDATE Mes_Config 
        SET 
            ERP_ORDER_CONFIRM = '1';

    COMMIT TRANSACTION
GO

--生产排程:订单报工重试
ALTER PROCEDURE  [dbo].[usp_Mfg_Wo_List_Roc_Redo]
     @WOID               AS INT                  --Mfg_WO_LIST更改ID
    ,@UserName           AS NVARCHAR(50)         --报完工人员
    ,@CatchError         AS INT           OUTPUT --系统判断用户操作异常的数量
    ,@RtnMsg             AS NVARCHAR(100) OUTPUT --返回状态
AS
    SET @CatchError = 0
    SET @RtnMsg     = ''

    IF (SELECT COUNT(1) FROM MFG_WO_List WHERE ID=@WOID) = 0
    BEGIN
        SET @CatchError = @CatchError + 1
        SET @RtnMsg     = '您要报完工的订单并不存在, 请刷新后重试! [WOID:' + CONVERT(VARCHAR(10), @WOID) + ']!'
        RETURN
    END

    DECLARE @MesStatus AS INT;
    SELECT @MesStatus = MAX(MesStatus) FROM MFG_WO_List WHERE ID=@WOID;

    IF @MesStatus <> 3 AND @MesStatus <> 2
    BEGIN
        SET @CatchError = @CatchError + 1
        SET @RtnMsg     = '您要修改的订单当前状态不是:已完成或生产进行中, 请核对订单状态! [WOID:' + CONVERT(VARCHAR(10), @WOID) + ']!'
        RETURN
    END

    BEGIN TRANSACTION
        UPDATE ERP_WO_REPORT_COMPLETE 
        SET 
             MesModifyTime = GETDATE()
            ,ErpCfmStatus  = 0
            ,MesCfmStatus  = 0
        WHERE WOID = @WOID 
          AND ErpCfmStatus = 2

        UPDATE MFG_WO_List SET
             Mes2ErpCfmStatus = 0
        WHERE ID = @WOID;

        --在全局状态表中设定更新的标志
        UPDATE Mes_Config 
        SET 
            ERP_ORDER_CONFIRM = '1';

    COMMIT TRANSACTION
GO


--生产排程:订单发料重试
ALTER PROCEDURE  [dbo].[usp_Mfg_Wo_List_Mvt_Redo]
     @WOID               AS INT                  --Mfg_WO_LIST更改ID
    ,@UserName           AS NVARCHAR(50)         --报完工人员
    ,@CatchError         AS INT           OUTPUT --系统判断用户操作异常的数量
    ,@RtnMsg             AS NVARCHAR(100) OUTPUT --返回状态
AS
    SET @CatchError = 0
    SET @RtnMsg     = ''

    IF (SELECT COUNT(1) FROM MFG_WO_List WHERE ID=@WOID) = 0
    BEGIN
        SET @CatchError = @CatchError + 1
        SET @RtnMsg     = '您要重试发料的订单并不存在, 请刷新后重试! [WOID:' + CONVERT(VARCHAR(10), @WOID) + ']!'
        RETURN
    END

    DECLARE @MesMvtStatus AS INT;
    SELECT @MesMvtStatus = MAX(Mes2ErpMVTStatus) FROM MFG_WO_List WHERE ID=@WOID;

    IF @MesMvtStatus <> 2
    BEGIN
        SET @CatchError = @CatchError + 1
        SET @RtnMsg     = '您要重试的订单当前状态不是发料失败状态, 请核对订单状态! [WOID:' + CONVERT(VARCHAR(10), @WOID) + ']!'
        RETURN
    END

    BEGIN TRANSACTION
        UPDATE ERP_WO_Material_Transfer 
        SET 
             MesModifyTime = GETDATE()
            ,ErpMvtStatus  = 0
            ,MesMvtStatus  = 0
        WHERE WOID = @WOID 
          AND ErpMvtStatus = 2

        UPDATE MFG_WO_List SET
             Mes2ErpMVTStatus = 0
        WHERE ID = @WOID;

        --在全局状态表中设定更新的标志
        UPDATE Mes_Config 
        SET 
            ERP_GOODSMVT_CREATE = '1';

    COMMIT TRANSACTION
GO

--生产排程:订单发料新增
ALTER PROCEDURE  [dbo].[usp_Mfg_Wo_List_Mvt_Add]
     @WOID               AS INT                  --Mfg_WO_LIST更改ID
    ,@UserName           AS NVARCHAR(50)         --报完工人员
    ,@CatchError         AS INT           OUTPUT --系统判断用户操作异常的数量
    ,@RtnMsg             AS NVARCHAR(100) OUTPUT --返回状态
AS
    --只把完成的主订单需要制作此记录输出即可.
    SET @CatchError = 0
    SET @RtnMsg     = '';

    IF (SELECT COUNT(1) FROM MFG_WO_List WHERE ID=@WOID) = 0
    BEGIN
        SET @CatchError = @CatchError + 1
        SET @RtnMsg     = '您要发料的订单并不存在, 请刷新后重试! [WOID:' + CONVERT(VARCHAR(10), @WOID) + ']!'
        RETURN
    END

    DECLARE @MesMvtStatus AS INT;
    SELECT @MesMvtStatus = MAX(Mes2ErpMVTStatus) FROM MFG_WO_List WHERE ID=@WOID;

    --只要发料一次, 标记位肯定不是-1, 即使重试过一次, 其也会是0值
    IF @MesMvtStatus <> -1
    BEGIN
        SET @CatchError = @CatchError + 1
        SET @RtnMsg     = '您要重试的订单当前状态不是未发料状态, 请核对订单状态! [WOID:' + CONVERT(VARCHAR(10), @WOID) + ']!'
        RETURN
    END

    BEGIN TRANSACTION    
        INSERT INTO ERP_WO_Material_Transfer 
               (WOID,  AUFNR,                       MATNR,                    MAKTX,        GAMNG,      FinishQty,    MesCreateUser, MesCreateTime, MesModifyTime, ErpMvtStatus, MesMvtStatus)
        SELECT  ID,   '0000' + ErpWorkOrderNumber, '00000000' + ErpGoodsCode, ErpGoodsDsca, ErpPlanQty, MesFinishQty, 'MES_SYS',     GETDATE(),     GETDATE(),     0,            0 
        FROM MFG_WO_List
        WHERE 
            ID = @WOID
        AND Mes2ErpMVTStatus =-1 


        UPDATE MFG_WO_List SET
            Mes2ErpMVTStatus = 0
        WHERE 
            ID = @WOID
        AND Mes2ErpMVTStatus =-1 

        --在全局状态表中设定更新的标志
        UPDATE Mes_Config 
        SET 
            ERP_GOODSMVT_CREATE = '1';

    COMMIT TRANSACTION
GO

--此处原本写的不好
--此存储过程实现的时候, 需要传递的参数过多(都是从客户端浏览器又重新上传来的:不安全且低效)[目前已经解决了, 一些参数已经可以省略了.]
--即:只需传递一下主订单的WoId,ItemNumber, Position, ProcessCode等信息
ALTER PROCEDURE  [dbo].[usp_Mfg_Wo_Mtl_List_Add_SubPlan]
     @WorkOrderNumber    AS VARCHAR (50)
    ,@WorkOrderVersion   AS INT  
    ,@InturnNumber       AS INT                  --当作LineNumber值来使用
    ,@ProcessCode        AS NVARCHAR(50)         --工序编号
    ,@ItemNumber         AS VARCHAR (50)         --物料编号
    ,@ItemDsca           AS NVARCHAR(50)         --物料描述
    ,@UOM                AS NVARCHAR(100)        --单位
    ,@LeftQty            AS NUMERIC (18, 4)      --剩余数量
    ,@RequireQty         AS NUMERIC (18, 4)      --需求数量
    ,@UpdateUser         AS NVARCHAR(100)        --操作者
    ,@CatchError         AS INT           OUTPUT --系统判断用户操作异常的数量
    ,@RtnMsg             AS NVARCHAR(100) OUTPUT --返回值
AS
    SET @CatchError = 0
    SET @RtnMsg     = '';

    INSERT INTO MFG_WO_MTL_List ( Qty,         LeftQty,  MesCreateUser,  MesModifyuser, WorkOrderVersion,  MesStatus, CommentReqNumber, CommentReqPosition, WorkOrderNumber,  ProcessCode,  ItemNumber, LineNumber, ItemDsca, UOM, WorkCenter, WcDsca, WHLocation, Phantom, [Bulk], BackFlush, WorkSite )
    SELECT                       @RequireQty, @LeftQty, @UpdateUser,  　@UpdateUser,   @WorkOrderVersion,  MesStatus, CommentReqNumber, CommentReqPosition, WorkOrderNumber,  ProcessCode,  ItemNumber, LineNumber, ItemDsca, UOM, WorkCenter, WcDsca, WHLocation, Phantom, [Bulk], BackFlush, WorkSite
    FROM MFG_WO_MTL_List
    WHERE 
         WorkOrderVersion = 0  
     AND WorkOrderNumber  = @WorkOrderNumber
     AND ProcessCode      = @ProcessCode    
     AND ItemNumber       = @ItemNumber
     AND UOM              = @UOM
GO

--取得订单的物料使用清单
ALTER PROCEDURE  [dbo].[usp_Mfg_Wo_Mtl_List_OneWo]
     @WOID   AS INT  --Mfg_WO_LIST.ID
AS
    SELECT
        MTL.*
    FROM Mfg_WO_MTL_List MTL, Mfg_WO_List WO
    WHERE
        MTL.WorkOrderNumber =WO.ErpWorkOrderNumber
    AND MTL.WorkOrderVersion=WO.MesWorkOrderVersion
    AND WO.ID=@WOID
    ORDER BY LineNumber;

    --准备后期定时刷新ERP系统的时时库存准备接口数据
    BEGIN TRAN
        --此处备份一下, 目的是为了方便调试, 防止当库存数据模块取回不来出现问题无从知晓.
        INSERT INTO Log_ERP_Inventory_List
              (ID, SOURCEID, MATNR, MAKTX, INVQTY, ErpUpdateTime, MesCreateTime )
        SELECT ID, SOURCEID, MATNR, MAKTX, INVQTY, ErpUpdateTime, MesCreateTime 
        FROM ERP_Inventory_List
        ORDER BY ID;
    
        DELETE FROM ERP_Inventory_List;
    
        INSERT INTO ERP_Inventory_List ( SOURCEID, MATNR, MAKTX )
        SELECT
            MTL.ID, '00000000' + ItemNumber, ItemDsca
        FROM Mfg_WO_MTL_List MTL, Mfg_WO_List WO
        WHERE
            MTL.WorkOrderNumber =WO.ErpWorkOrderNumber
        AND MTL.WorkOrderVersion=WO.MesWorkOrderVersion
        AND WO.ID=@WOID
        ORDER BY LineNumber;
    
        UPDATE Mes_Config 
        SET 
            ERP_INVENTORY_DATA = '1';   
     COMMIT;

GO

--取得订单的物料的ERP库存
ALTER PROCEDURE  [dbo].[usp_Mfg_Wo_Mtl_List_Inv]
     @WOID   AS INT  --Mfg_WO_LIST.ID
AS
    SELECT
        INV.*
    FROM ERP_Inventory_List INV, Mfg_WO_MTL_List MTL, Mfg_WO_List WO
    WHERE
        MTL.WorkOrderNumber =WO.ErpWorkOrderNumber
    AND MTL.WorkOrderVersion=WO.MesWorkOrderVersion
    AND INV.SOURCEID = MTL.ID 
    AND INV.INVQTY IS NOT NULL
    AND WO.ID  = @WOID
    ORDER BY SOURCEID;

GO

--取得当日设备保养计划
ALTER PROCEDURE  [dbo].[usp_PMPlan_List_get_today]
AS
    SELECT
         ProcList.ProcessName ProcessName
        ,PmPlan.DeviceName DeviceName
        ,PmPlan.PmPlanName PmPlanName
        ,FORMAT(PmPlan.PmFirstDate, 'yyyy-MM-dd') PmFirstDate
        ,FORMAT(DateAdd(mi, PmPlan.PmCycleTime, CONVERT(DATETIME,PmPlan.PmFirstDate)),'yyyy-MM-dd') PmFinishDate
        ,PmPlan.PmTimeUsage PmTimeUsage
    FROM Equ_PmPlanList PmPlan
    JOIN Mes_Process_List ProcList on PmPlan.ProcessCode = ProcList.ProcessCode
    WHERE
        PmPlan.PmFirstDate = CONVERT(DATE,GETDATE())
GO

--产品物料编码维护 -> 获取清单
ALTER PROCEDURE  [dbo].[usp_Mes_Mub_List]
     @GoodsCode          AS VARCHAR  (50)    = ''    --产品的物料编码
    ,@TargetFileName     AS NVARCHAR (50)    = ''    --文件上传之后在服务器上保留的文件名称 
    ,@OPtype             AS VARCHAR  (50)    = ''    --用以判断是刚刚上传的数据文件的返显还是显示数据库中的配置文件的显示
AS
    IF @OPtype = 'UPLOADREVIEW'
    BEGIN    
        SELECT * 
        FROM Mes_Mub_List_UP
        WHERE 
            TargetFileName = @TargetFileName
        AND GoodsCode      = '0000000000'
        ORDER BY ID;
    END
    ELSE
    BEGIN
        SELECT * 
        FROM Mes_Mub_List
        WHERE 
            GoodsCode      = @GoodsCode
        ORDER BY ID;
    END  
GO

--产品物料编码维护 -> 获取清单模板(物料分布)下载
ALTER PROCEDURE  [dbo].[usp_Mes_Mub_List_Template]
     @GoodsCode          AS VARCHAR  (50)    = ''    --产品的物料编码
    ,@TargetFileName     AS NVARCHAR (50)    = ''    --文件上传之后在服务器上保留的文件名称 
    ,@OPtype             AS VARCHAR  (50)    = ''    --用以判断是刚刚上传的数据文件的返显还是显示数据库中的配置文件的显示
AS
        SELECT 
             GoodsCode   [产品物料编码(参考列,上传时被忽略)]
            ,ItemNumber  [物料编码(可以修改)]
            ,ItemDsca    [物料描述(可以修改)]
            ,ProcessCode [工序编号(可以修改)]
            ,ProcessName [工序名称(可以修改)]
            ,MubPercent  [工序用料占比%(可以修改)]
        FROM Mes_Mub_List
        WHERE 
            GoodsCode = @GoodsCode

        UNION ALL
        
        SELECT 
             @GoodsCode
            ,'0000000000'
            ,'样例物料,只为提供工序编号和名称,上传时会被忽略'
            ,ProcessCode
            ,ProcessName
            ,0.0 
        FROM 
            Mes_Process_List 
GO

--产品物料编码维护 -> 保存数据
ALTER PROCEDURE  [dbo].[usp_Mes_Mub_List_Save]
     @TargetFileName     AS NVARCHAR (50)    = ''    --文件上传之后在服务器上保留的文件名称 
    ,@GoodsCode          AS VARCHAR  (50)    = ''    --产品的物料编码
    ,@UploadUser         AS NVARCHAR (50)    = N''   --更新用户
    ,@CatchError         AS INT           OUTPUT --系统判断用户操作异常的数量
    ,@RtnMsg             AS NVARCHAR(100) OUTPUT --返回状态
AS
    SET @CatchError = 0
    SET @RtnMsg     = ''
    IF @TargetFileName = ''
    BEGIN
        SET @CatchError = 1;
        SET @RtnMsg = '没有找到上传成功的文件';
        RETURN;
    END

    DECLARE @ExistCount INT;
    SELECT 
         @ExistCount = COUNT(1) 
    FROM 
    Mes_Mub_List_UP
    WHERE 
          TargetFileName = @TargetFileName 
      AND GoodsCode      = '0000000000'

    IF @ExistCount = 0 
    BEGIN
        SET @CatchError = 1;
        SET @RtnMsg = '系统未发现您曾经上传过有效数据记录!';
        RETURN;
    END

    SELECT 
         @ExistCount = COUNT(1) 
    FROM 
    Mes_Mub_List_UP
    WHERE 
          TargetFileName = @TargetFileName 
      AND GoodsCode      = '0000000000'
      AND ProcessCode NOT IN (SELECT ProcessCode FROM Mes_Process_List)   
     
    IF @ExistCount > 0 
    BEGIN
        SET @CatchError = 1;
        SET @RtnMsg = '系统发现您上传的数据记录中有不认识的工序编号, 请核对后重新上传!';
        RETURN;
    END

    DELETE FROM Mes_Mub_List WHERE GoodsCode = @GoodsCode;

    INSERT INTO Mes_Mub_List ([GoodsCode],  [ItemNumber],  [ItemDsca],  [ProcessCode],  [ProcessName],  [MubPercent],  [UploadUser])
    SELECT                    @GoodsCode,   [ItemNumber],  [ItemDsca],  [ProcessCode],  [ProcessName],  [MubPercent],  @UploadUser

    FROM 
    Mes_Mub_List_UP
    WHERE 
          TargetFileName = @TargetFileName 
      AND GoodsCode      = '0000000000';

    RETURN
GO

--产品物料编码维护 -> 新增产品
ALTER PROCEDURE  [dbo].[usp_Mes_Mub_List_Add]
     @TargetFileName     AS NVARCHAR (50)    = ''    --文件上传之后在服务器上保留的文件名称 
    ,@GoodsCode          AS VARCHAR  (50)    = ''    --产品的物料编码
    ,@ItemNumber         AS VARCHAR  (50)    = ''    --原料编码
    ,@ItemDsca           AS NVARCHAR (50)    = ''    --物料描述
    ,@ProcessCode        AS VARCHAR  (50)    = ''    --工序编号
    ,@ProcessName        AS NVARCHAR (50)    = N''   --工序名称
    ,@MubPercent         AS NUMERIC  (18, 4) = 100   --PLC计数用量
    ,@UploadUser         AS NVARCHAR (50)    = N''   --更新用户
    ,@CatchError         AS INT           OUTPUT --系统判断用户操作异常的数量
    ,@RtnMsg             AS NVARCHAR(100) OUTPUT --返回状态
AS
    SET @CatchError = 0
    SET @RtnMsg     = ''

    INSERT INTO Mes_Mub_List_UP
    ( [TargetFileName],  [GoodsCode],  [ItemNumber],  [ItemDsca],  [ProcessCode],  [ProcessName],  [MubPercent],  [UploadUser]) VALUES
    ( @TargetFileName,   @GoodsCode,   @ItemNumber,   @ItemDsca,   @ProcessCode,   @ProcessName,   @MubPercent,   @UploadUser );
    RETURN
GO

--产品物料编码维护 -> 新增产品
ALTER PROCEDURE  [dbo].[usp_Mes_Goods_List_Add]
     @GoodsCode          AS VARCHAR  (50) --产品的物料编码
    ,@GoodsDsca          AS NVARCHAR (50) --产品的物料描述
    ,@DimLength          AS INT           --长度(mm)
    ,@DimHeight          AS INT           --高端(mm)
    ,@DimWidth           AS INT           --宽度(mm)
    ,@UnitCostTime       AS INT           --单位生产耗时(分钟)
    ,@UpdateUser         AS NVARCHAR (50) --更新用户
    ,@CatchError         AS INT           OUTPUT --系统判断用户操作异常的数量
    ,@RtnMsg             AS NVARCHAR(100) OUTPUT --返回状态
AS
    SET @CatchError = 0
    SET @RtnMsg     = ''

    IF (SELECT COUNT(1) FROM Mes_Goods_List WHERE GoodsCode=@GoodsCode) > 0
    BEGIN
        SET @CatchError = @CatchError + 1
        SET @RtnMsg     = '此产品物料编码已经存在, 请核对!：' + @GoodsCode + '!'
        RETURN
    END

    BEGIN TRANSACTION

    INSERT INTO Mes_Goods_List
    ( GoodsCode,  GoodsDsca,  DimLength,  DimHeight,  DimWidth,  UnitCostTime,  UpdateUser, UpdateTime) VALUES
    (@GoodsCode, @GoodsDsca, @DimLength, @DimHeight, @DimWidth, @UnitCostTime, @UpdateUser, GETDATE());

    DECLARE @ID INT;
    DECLARE @TT INT;

    IF (SELECT COUNT(1) FROM Mes_PLC_List WHERE GoodsCode = @GoodsCode) > 0
    BEGIN
        --此处删除的目的是防止用户从前已经建立过此物料号码, 后来删除了, 后期又重新新增进来了.
        --删除的目的是打扫一下环境.
        DELETE FROM Mes_PLC_Parameters
        WHERE
        PLCID IN(
            SELECT ID
            FROM Mes_PLC_List
            WHERE GoodsCode = @GoodsCode
        );
        DELETE FROM Mes_PLC_List WHERE GoodsCode = @GoodsCode;
    END

    DECLARE RECPLC CURSOR FOR
    SELECT ID FROM Mes_PLC_List WHERE GoodsCode = '0000000000' ORDER BY ID;
    OPEN RECPLC;

    FETCH NEXT FROM RECPLC INTO @ID;
    WHILE @@FETCH_STATUS = 0
    BEGIN

    --逐个PLC插入
        INSERT INTO Mes_PLC_List (  GoodsCode, PLCName, PLCCode, PLCType, PLCModel, PLCCabinet, ProcessCode,  UpdateUser )
                            SELECT @GoodsCode, PLCName, PLCCode, PLCType, PLCModel, PLCCabinet, ProcessCode, @UpdateUser
                            FROM Mes_PLC_List
                            WHERE ID = @ID;

    --获取最后一个刚刚插入记录的ID  (本连接的,当下作用域之内的新增ID值)
        SELECT @TT = SCOPE_IDENTITY()

    --每个PLC的所有参数都复制一遍
        INSERT INTO Mes_PLC_Parameters( PLCID, ParamName, ParamDsca, ParamValue, ParamType, ProcessCode, ApplModel, ApplData, OperateType, OperateCommand, ItemNumber,  UpdateUser )
                                 SELECT @TT,   ParamName, ParamDsca, ParamValue, ParamType, ProcessCode, ApplModel, ApplData, OperateType, OperateCommand, ItemNumber, @UpdateUser
                                 FROM Mes_PLC_Parameters
                                 WHERE PLCID = @ID;

        FETCH NEXT FROM RECPLC INTO @ID;
    END

    CLOSE RECPLC;
    DEALLOCATE RECPLC;

    COMMIT TRANSACTION
    RETURN
GO

--产品物料编码维护 -> 修改产品
ALTER PROCEDURE  [dbo].[usp_Mes_Goods_List_Edit]
     @GoodsCode          AS VARCHAR  (50) --产品的物料编码
    ,@GoodsDsca          AS NVARCHAR (50) --产品的物料描述
    ,@DimLength          AS INT           --长度(mm)
    ,@DimHeight          AS INT           --高端(mm)
    ,@DimWidth           AS INT           --宽度(mm)
    ,@UnitCostTime       AS INT           --单位生产耗时(分钟)
    ,@UpdateUser         AS NVARCHAR (50) --更新用户
    ,@GoodsID            AS INT           --待修改记录的ID
    ,@CatchError         AS INT           OUTPUT --系统判断用户操作异常的数量
    ,@RtnMsg             AS NVARCHAR(100) OUTPUT --返回状态
AS
    SET @CatchError = 0
    SET @RtnMsg     = ''

    IF (SELECT COUNT(1) FROM Mes_Goods_List WHERE GoodsCode=@GoodsCode and ID<>@GoodsID) > 0
    BEGIN
        SET @CatchError = @CatchError + 1
        SET @RtnMsg     = '此产品物料编码已经存在, 请核对!：' + @GoodsCode + '!'
        RETURN
    END

    BEGIN TRANSACTION

    DECLARE @OLD_GoodsCode AS VARCHAR(50);
    SELECT @OLD_GoodsCode = GoodsCode FROM Mes_Goods_List WHERE ID = @GoodsID;

    UPDATE Mes_Goods_List
    SET
         GoodsCode    = @GoodsCode
        ,GoodsDsca    = @GoodsDsca
        ,DimLength    = @DimLength
        ,DimHeight    = @DimHeight
        ,DimWidth     = @DimWidth
        ,UnitCostTime = @UnitCostTime
        ,UpdateUser   = @UpdateUser
        ,UpdateTime   = GETDATE()
    WHERE ID=@GoodsID;

    UPDATE Mes_PLC_List
    SET
        GoodsCode = @GoodsCode
    WHERE
        GoodsCode = @OLD_GoodsCode;

    COMMIT TRANSACTION
    RETURN
GO

--产品物料编码维护 -> 删除产品
ALTER PROCEDURE  [dbo].[usp_Mes_Goods_List_Delete]
     @GoodsID            AS INT                  --待修改记录的ID
    ,@CatchError         AS INT           OUTPUT --系统判断用户操作异常的数量
    ,@RtnMsg             AS NVARCHAR(100) OUTPUT --返回状态
AS
    SET @CatchError = 0
    SET @RtnMsg     = ''

    BEGIN TRANSACTION

    DECLARE @GoodsCode VARCHAR(50);

    IF (SELECT COUNT(1) FROM Mes_Goods_List WHERE ID = @GoodsID) > 0
    BEGIN
        SELECT @GoodsCode = GoodsCode FROM Mes_Goods_List WHERE ID = @GoodsID;

        DELETE FROM Mes_PLC_Parameters
        WHERE
        PLCID IN(
            SELECT ID
            FROM Mes_PLC_List
            WHERE GoodsCode = @GoodsCode
        );
        DELETE FROM Mes_PLC_List WHERE GoodsCode = @GoodsCode;
        DELETE FROM Mes_Goods_List WHERE ID = @GoodsID;
    END

    COMMIT TRANSACTION
    RETURN
GO

--获得Threshold清单
ALTER PROCEDURE [dbo].[usp_Mes_Threshold_List]
         @ItemNumber           AS VARCHAR(50) = '' --物料编号
        ,@ProcessCode          AS VARCHAR(50) = '' --工序编号, 如果不设置这个参数, 
    AS
        SELECT AA.*, 
        ISNULL(BB.ProcessName, '' ) ProcessName
    FROM Mes_Threshold_List AA 
    LEFT JOIN Mes_Process_List BB on AA.ProcessCode=BB.ProcessCode 
    WHERE   ( AA.ItemNumber  = @ItemNumber OR @ItemNumber = '' )
        AND ( BB.ProcessCode = @ProcessCode OR @ProcessCode = '')
    ORDER BY AA.ProcessCode
GO


--获得PLC清单
ALTER PROCEDURE [dbo].[usp_Mes_Plc_List]
     @GoodsCode            AS VARCHAR(50)        --产品编号
    ,@SenderType           AS VARCHAR(50) = 'VS' --发送数据的类型: VS, CS
AS
    SELECT 
        Mes_PLC_List.*, 
        ISNULL(Mes_Process_List.ProcessName,'') ProcessName
    FROM Mes_PLC_List 
        LEFT JOIN Mes_Process_List 
               ON Mes_Process_List.ProcessCode = Mes_PLC_List.ProcessCode
    WHERE 
         (Mes_PLC_List.GoodsCode   = @GoodsCode)
     AND (Mes_PLC_List.ID IN (SELECT DISTINCT PLCID
                                 FROM Mes_PLC_Parameters
                                 WHERE OperateType IN ( 'W', 'RW') AND ApplModel = @SenderType)
     )
    ORDER BY ProcessCode, PLCCabinet, PLCName
GO

--获得指定的PLC的配置参数清单
ALTER PROCEDURE [dbo].[usp_Mes_Plc_Parameters_List]
     @PLCID            AS INT                      --PLCID
    ,@TargetFileName   AS NVARCHAR (50)    = ''    --文件上传之后在服务器上保留的文件名称 
    ,@UploadView       AS VARCHAR  (50)    = ''    --用以判断是刚刚上传的数据文件的返显还是显示数据库中的配置文件的显示
AS
    IF @UploadView = 'UPLOADREVIEW'
    BEGIN
        SELECT 
             PAM.ID
            ,PAM.PLCID
            ,PAM.ParamName
            ,PAM.ParamDsca
            ,ISNULL(PUP.ParamValue, PAM.ParamValue) ParamValue
            ,PAM.ParamType
            ,PAM.OperateType
            ,PAM.ItemNumber
        FROM Mes_PLC_Parameters PAM
            LEFT JOIN Mes_PLC_Parameters_UP PUP ON PAM.ID = PUP.PAMID             
        WHERE 
            PAM.PLCID     = @PLCID
        AND PAM.ApplModel = 'VS'
        AND PAM.OperateType IN ( 'W', 'RW') 
        AND PUP.TargetFileName = @TargetFileName
        ORDER BY ParamName
    END 
    ELSE
    BEGIN
        SELECT 
             ID
            ,PLCID
            ,ParamName
            ,ParamDsca
            ,ParamValue
            ,ParamType
            ,OperateType
            ,ItemNumber
        FROM Mes_PLC_Parameters
        WHERE 
            PLCID = @PLCID
        AND OperateType IN ( 'W', 'RW') 
        AND ApplModel = 'VS'
        ORDER BY ParamName
    END
GO

--产品物料编码维护 -> 新增产品
ALTER PROCEDURE  [dbo].[usp_Mes_Plc_Parameters_Upload]
     @PLCID              AS INT                      --PLC标识字
    ,@PAMID              AS INT                      --参数标识字
    ,@ParamValue         AS VARCHAR  (50)            --参数值
    ,@TargetFileName     AS NVARCHAR (50)    = ''    --文件上传之后在服务器上保留的文件名称 
    ,@UploadUser         AS NVARCHAR (50)    = N''   --更新用户
    ,@CatchError         AS INT           OUTPUT     --系统判断用户操作异常的数量
    ,@RtnMsg             AS NVARCHAR(100) OUTPUT     --返回状态
AS
    SET @CatchError = 0
    SET @RtnMsg     = ''

    INSERT INTO Mes_PLC_Parameters_UP
    ( [TargetFileName],  [PLCID],  [PAMID],  [ParamValue],  [UploadUser]) VALUES
    ( @TargetFileName,   @PLCID,   @PAMID,   @ParamValue,   @UploadUser );
    RETURN
GO

--获得指定的PLC的配置参数清单(配置文件下载之用)
ALTER PROCEDURE [dbo].[usp_Mes_Plc_Parameters_List_Template]
     @GoodsCode            AS VARCHAR(50)      --产品编号
AS

    SELECT 
        PLC.ID                     [PLC标识字(不要修改)],
        PAM.ID                     [参数标识字(不要修改)],
        @GoodsCode                 [产品编码(参考列,上传时会被忽略)],
        ISNULL(PRS.ProcessName,'') [工序名称(参考列,上传时会被忽略)],
        PLC.PLCCabinet             [电器机柜(参考列,上传时会被忽略)],
        PLC.PLCName                [PLC名称(参考列,上传时会被忽略)],
        PAM.ParamName              [参数名称(参考列,上传时会被忽略)],
        PAM.ParamDsca              [参数描述(参考列,上传时会被忽略)],
        PAM.ParamType              [参数类型(参考列,上传时会被忽略)],
        PAM.ParamValue             [参数值(可修改)]
    FROM Mes_PLC_List PLC
      INNER JOIN Mes_PLC_Parameters PAM ON PLC.ID = PAM.PLCID
      LEFT JOIN Mes_Process_List PRS ON PRS.ProcessCode = PLC.ProcessCode
    WHERE 
         PLC.GoodsCode = @GoodsCode
     AND PAM.ApplModel = 'VS'     
     AND PAM.OperateType IN ( 'W', 'RW') 
    ORDER BY 
         PLC.ProcessCode, PLC.PLCCabinet, PLC.PLCName
GO

--获得PLC物料拉动参数清单
ALTER PROCEDURE [dbo].[usp_Mes_Plc_Pull_List]
     @GoodsCode            AS VARCHAR(50)      --产品编号
    ,@ProcessCode          AS VARCHAR(50) = '' --工序编号, 如果不设置这个参数, 
AS
    SELECT 
        Mes_PLC_List.*, 
        ISNULL(Mes_Process_List.ProcessName,'') ProcessName
    FROM Mes_PLC_List 
        LEFT JOIN Mes_Process_List 
               ON Mes_Process_List.ProcessCode = Mes_PLC_List.ProcessCode
    WHERE 
         (Mes_PLC_List.GoodsCode   = @GoodsCode)
     AND (Mes_PLC_List.ProcessCode = @ProcessCode OR @ProcessCode = '')
     AND (Mes_PLC_List.ID IN (SELECT DISTINCT PLCID
                                 FROM Mes_PLC_Parameters
                                 WHERE ApplModel = 'MT')
     )
    ORDER BY ProcessCode, PLCCabinet, PLCName
GO

--获得指定的PLC的物料拉动参数清单
ALTER PROCEDURE [dbo].[usp_Mes_Plc_Pull_Parameters_List]
     @PLCID            AS INT                  --PLCID
AS
     SELECT PARA.*, ATTA.AttaQty
     FROM 
         Mes_PLC_Parameters PARA
     LEFT JOIN 
         (SELECT Mes_Mtl_Pull_Item_Attached.MainItem, SUM(1) AttaQty 
          FROM Mes_Mtl_Pull_Item_Attached, Mes_PLC_List PLC
          WHERE 
               PLC.ID = @PLCID
           AND Mes_Mtl_Pull_Item_Attached.GoodsCode = PLC.GoodsCode
          GROUP BY MainItem
         ) AS ATTA ON ATTA.MainItem = PARA.ItemNumber
     WHERE 
          PARA.PLCID = @PLCID
      AND PARA.ApplModel = 'MT'
     ORDER BY PARA.ParamName
GO


--获得发送参数的PLC清单
ALTER PROCEDURE [dbo].[usp_Mes_Plc_Send_Status]
     @BatchNo            AS VARCHAR(15)      --发送批次号
AS

  --注意: PLC设备的派发状态定义和其下边所属的参数派发状态定义不一致:
  --在PLC设备的派发状态中, 是根据所有参数的统计结果(是一个中间态)
    SELECT
      PLCID
     ,CASE
          WHEN MAX(Status) = 0 AND MIN(Status) = 0 THEN 0
          WHEN MAX(Status) = 1 AND MIN(Status) = 1 THEN 1
          WHEN MAX(Status) <> MIN(Status) AND MIN(Status) > -2 THEN 1
          WHEN MIN(Status) = 2 THEN  2
          WHEN MIN(Status)<=-2 THEN -2
          ELSE                      -1
      END StatusValue
     ,CASE
          WHEN MAX(Status) = 0 THEN  '等待派发中'
          WHEN MAX(Status) = 1 THEN  '正在派发中...'
          WHEN MAX(Status) <> MIN(Status) AND MIN(Status) > -2 THEN '正在派发中......'   --此处提示字比状态1多了三个点
          WHEN MIN(Status) = 2 THEN  '派发成功!'
          WHEN MIN(Status)<=-2 THEN  '派发失败!'
          ELSE                       '获取状态中...'
      END StatusTip
    FROM [dbo].[Mes_PLC_TransInterface]
    --当下加入了这个条件, 但是其是一个很不好的条件设定,
    --最终可能会给用户带来操作层面的迷惑或不知所措的局面:等待界面刷新出是否发生了发送完成时, 定时器到期了.(目前只好设定等待时间超长才可以解决这个问题)
    --但是: 如果不加入这个条件限定, 可能就会出现不允许再次派发曾经发生失败的设备的尴尬境地.
    WHERE BATCHNUM = @BatchNo
    GROUP BY PLCID
    ORDER BY PLCID
GO

--获得指定的PLC的发送参数清单
ALTER PROCEDURE [dbo].[usp_Mes_Plc_Parameters_Send_Status]
    @PLCID            AS INT                  --PLCID
AS  
    SELECT
         SOURCEID   ParamID
        ,ParamValue ParamValue
        ,Status     StatusValue
        ,CASE
           WHEN  Status = 0 THEN '等待派发'
           WHEN  Status = 1 THEN '正在派发'
           WHEN  Status = 2 THEN '派发成功'
           WHEN  Status<=-2 THEN '派发失败'
           ELSE                  ''
        END
                    StatusTip
    FROM [Mes_PLC_TransInterface]
    WHERE PLCID = @PLCID AND Status <= -2
    ORDER BY ParamID
GO

--PLC参数派发, 产生待派发记录集并插入接口表中.
ALTER PROCEDURE  [dbo].[usp_Mes_Plc_Parameters_Send]
     @IDLIST             AS VARCHAR(MAX)
    ,@OperateUser        AS NVARCHAR(50)
    ,@WorkOrderNumber    AS VARCHAR(50)   = ''
    ,@WorkOrderVersion   AS INT           = 0
    ,@SenderType         AS VARCHAR(50)   = 'VS' --发送的数据类型: VS, CS
    ,@ParamsCount        AS INT           OUTPUT --此次派发时使用的派发参数数量
    ,@BatchNo            AS VARCHAR(15)   OUTPUT --此次派发时使用的派发批次号
    ,@CatchError         AS INT           OUTPUT --系统判断用户操作异常的数量
    ,@RtnMsg             AS NVARCHAR(100) OUTPUT --返回状态
AS
    SET @CatchError = 0 ;
    SET @RtnMsg     = '';

    DECLARE @cIndex INT;
    DECLARE @sIdList VARCHAR(MAX);
    DECLARE @ListTB TABLE(PLCID INT);

    SELECT @sIdList = @IDLIST;
    SELECT @cIndex = CHARINDEX(',', @sIdList);
    WHILE @cIndex>0
    BEGIN
        INSERT INTO @ListTB VALUES(CONVERT(INT, LEFT(@sIdList, @cIndex - 1)));
        SELECT @sIdList = RIGHT(@sIdList, LEN(@sIdList) - @cIndex);
        SELECT @cIndex = CHARINDEX(',', @sIdList, @cIndex);
    END

    IF LEN(@sIdList) > 0
    BEGIN
        INSERT INTO @ListTB VALUES(CONVERT(INT, @sIdList));
    END

    DECLARE @iFounded INT;
    DECLARE @OperateTime DATETIME;
    DECLARE @LastBatchNo VARCHAR(20);
    SELECT
         @iFounded    = COUNT(1)
       , @OperateTime = MAX(OperateTime)
       , @LastBatchNo = MAX(BATCHNUM)
    FROM Mes_PLC_TransInterface MPT, @ListTB LTB
    WHERE MPT.PLCID=LTB.PLCID
      AND ( MPT.Status = 0
         OR MPT.Status = 1 );

    IF @iFounded > 0
    BEGIN
        SET @CatchError = @CatchError + 1
        SET @RtnMsg     = '您选中的PLC设备尚有 ' + CONVERT(VARCHAR(10), @iFounded) + ' 条参数处于等待派发状态;' + CHAR(13)
                        + '其最后派发时间为: ' + CONVERT(VARCHAR(20), @OperateTime, 120) + ';' + CHAR(13)
                        + '派发单子号为: ' + @LastBatchNo + ';' + CHAR(13)
                        + '不要重复提交, 请稍后重试!'
        RETURN
    END

    EXEC usp_Mes_getNewSerialNo_Output 'MES2PLC','M2P', 10, @BatchNo OUTPUT;

    --开始真正的插入到接口表的操作.
    --此处对于 参数派发(VS) 和 产品变更指令(CS) 都不加区别的进行发送, 然后后续代码再依据不同的命令类型进行调整.
    INSERT INTO Mes_PLC_TransInterface ( BATCHNUM, PLCID, SOURCEID, ParamName, ParamType, ParamValue, OperateCommand, OperateUser,  Status)
                                  SELECT @BatchNo, PLCID, ID,       ParamName, ParamType, CASE WHEN ApplModel = 'VS' THEN ParamValue ELSE '1' END , OperateCommand, @OperateUser, 0
                                  FROM Mes_PLC_Parameters
                                  WHERE PLCID IN ( SELECT PLCID FROM @ListTB)
                                  AND OperateType IN ( 'W', 'RW') 
                                  AND ApplModel = @SenderType;

    --参数派发, 需要派发计划产量信息.
    IF @SenderType = 'VS'
    BEGIN
        DECLARE @PrsPlanQty  INT; --Process计划数量
        SELECT
             @PrsPlanQty = MesPlanQty        
        FROM
             MFG_WO_List
        WHERE
            ErpWorkOrderNumber  = @WorkOrderNumber
        AND MesWorkOrderVersion = @WorkOrderVersion;
 
        --更改工单的状态为产前调整中
        UPDATE MFG_WO_List
        SET 
            MesStatus = 1
        FROM 
            Mes_PLC_List
        WHERE 
            MesStatus = 0
        AND ErpWorkOrderNumber  = @WorkOrderNumber
        AND MesWorkOrderVersion = @WorkOrderVersion

        --计划产量,这里实现的很不好, 需要考虑工单数量,未完工数量,报废数量 
        --目前看来, 这个数量的复杂计算没有必要了, 我们仅仅把计划数量放入即可了, 也许不必[需要重写]
        INSERT INTO Mes_PLC_TransInterface ( BATCHNUM, PLCID, SOURCEID, ParamName, ParamType,  ParamValue, OperateCommand,  OperateUser, Status)
                                      SELECT @BatchNo, PLCID, ID,       ParamName, ParamType, @PrsPlanQty, OperateCommand, @OperateUser, 0
                                      FROM Mes_PLC_Parameters
                                      WHERE PLCID IN ( SELECT PLCID FROM @ListTB)
                                      AND OperateType IN ( 'W', 'RW') 
                                      AND ApplModel = 'QS';
    END

    --发送的是产品变更指令, 因此需要此时设定工位的下一个工单信息, 此处是需要现场的CT信号由1改变为0的触发(存储过程: usp_Mfg_Plc_Trig_CT)相配合来完成.
    IF @SenderType = 'CS'
    BEGIN
        UPDATE Mes_Process_List
        SET 
             NextWorkOrderNumber  = @WorkOrderNumber
            ,NextWorkOrderVersion = @WorkOrderVersion
        FROM 
            Mes_PLC_List         
        WHERE 
            Mes_PLC_List.ProcessCode = Mes_Process_List.ProcessCode 
        AND Mes_PLC_List.ID IN (SELECT PLCID FROM @ListTB)
    END

    SELECT @ParamsCount = COUNT(1)
    FROM Mes_PLC_TransInterface
    WHERE BATCHNUM = @BatchNo;

    RETURN
GO

--Mes系统参数配置
ALTER PROCEDURE  [dbo].[usp_Mes_Config]
     @ReadWriteFlag      AS VARCHAR(20)
    ,@ID                 AS INT
    ,@ParamName          AS VARCHAR(20)
    ,@InValue            AS VARCHAR(20)
    ,@OutValue           AS VARCHAR(20)   OUTPUT
    ,@CatchError         AS INT           OUTPUT --系统判断用户操作异常的数量
    ,@RtnMsg             AS NVARCHAR(100) OUTPUT --返回状态
AS
    SET @CatchError = 0
    SET @RtnMsg     = ''

    DECLARE @SQL NVARCHAR(500);

    IF @ReadWriteFlag = 'WRITE'
    BEGIN
        SELECT @SQL = 'UPDATE MES_CONFIG SET ' + @ParamName + '=@PValue WHERE ID= ' + CAST(@ID AS VARCHAR(10));
        EXEC SP_EXECUTESQL @SQL, N'@PValue AS VARCHAR(20)', @PValue=@InValue;
    END

    SELECT @SQL = N'SELECT @PValue=' + @ParamName + ' FROM MES_CONFIG WHERE ID=' + CAST(@ID AS VARCHAR(10));
    EXEC SP_EXECUTESQL @SQL, N'@PValue AS VARCHAR(20) OUTPUT', @PValue=@OutValue OUTPUT;

 --   SELECT @SQL = 'SELECT ' + @ParamName + ' FROM MES_CONFIG WHERE ID=' + CAST(@ID AS VARCHAR(10));
 --   CREATE TABLE #T(PVALUE VARCHAR(20));
 --   INSERT INTO  #T EXEC(@SQL);
 --   SET @OutValue = (SELECT PVALUE FROM #T);
 --   DROP TABLE #T;

    RETURN
GO


--用以获得MES序列号值, 此存储过程是实施后正式使用的.
--模块接口用户Proc_RFID_Interface会调用此存储过程.
ALTER PROCEDURE [dbo].[usp_Mes_getWoMesCode]
      @WorkOrderNumber  AS VARCHAR (50)  = ''     --工单号码
     ,@MesCode          VARCHAR(50)          OUTPUT   --获得新的Mes码值 
     ,@CatchError       AS INT           = 0 OUTPUT   --这是一个输入输出参数: 
                                                      --  作为输入时: 0:正常产生新Mes码; -1: 说明客户已经确认当前工单状态可以从待产直接跳转为正在生产中状态. 
                                                      --  作为输出时: 0:产生了新的Mes码;  1: 则说明肯定有错误出现, 此时需要查看RtnMsg的详细描述
     ,@RtnMsg           AS NVARCHAR(100) ='' OUTPUT   --返回状态的字符串描述
AS
    DECLARE @sDate        VARCHAR(10);
    DECLARE @sLine        VARCHAR(2);
    DECLARE @sSerialNo    VARCHAR(4);
    DECLARE @iRowCount    INT;
    DECLARE @iUbound      INT;
    DECLARE @iPlanQty     INT;
    DECLARE @iDiscardQty  INT;
    DECLARE @iLowerVDQty  INT;
    DECLARE @iStatus      INT;
    DECLARE @iVersion     INT;

    --先进行返回值的初始化 
    SET @RtnMsg  = '';  
    SET @MesCode = '';
    SET @iStatus = -1;

    SELECT 
         @iRowCount   = COUNT(1) 
        ,@iVersion    = MAX(MesWorkOrderVersion) --这里取最大值, 可能取得的是正常订单的值, 也可能是下线补单的值, 但是系统默认为当下不会存在两个同时在产的订单.     
        ,@iUbound     = MAX(MesCodeUBound)       --这里取最大值, 其实就是取得的version=0时的值, 因为, 我们只对version=0的记录进行记录
        ,@iPlanQty    = MAX(MesPlanQty)          --这里取最大值, 其实就是取得的version=0时的值
        ,@iDiscardQty = SUM(MesDiscardQty1 + MesDiscardQty2 + MesDiscardQty3 + MesDiscardQty4)
    FROM MFG_WO_List
    WHERE 
         ErpWorkOrderNumber = @WorkOrderNumber;

    IF @iRowCount = 0
    BEGIN
        SET @CatchError = 1;
        SET @RtnMsg     = '没有找到您录入的订单信息, 请您确认录入的订单是否正确!';
        RETURN;
    END

    IF @iUbound >= @iPlanQty + @iDiscardQty  --最初的计划数量 + 各版本数量之和 即为最后可以生成的MES码的数量.
    BEGIN
        SET @CatchError = 1;
        SET @RtnMsg     = '已经达到此订单MES码的数量上限了, 不可以继续生成MES码了!';
        RETURN;
    END

    --取得小于当下订单版本的订单的报废下线总和.
    SELECT @iLowerVDQty = SUM(MesDiscardQty1 + MesDiscardQty2 + MesDiscardQty3 + MesDiscardQty4)
    FROM MFG_WO_List
    WHERE 
         ErpWorkOrderNumber  = @WorkOrderNumber
     AND MesWorkOrderVersion < @iVersion; --此处的条件不可以包含:等于

     IF @iLowerVDQty IS NULL
     BEGIN
        SET @iLowerVDQty = 0; --0: 说明是原始订单; >0: 说明是下线补单
     END

    --如果当下的订单的计数是新产生的, 则要更新订单的状态为"生产进行中"
    IF     @iUbound = 0                               --说明是原始订单
        OR @iUbound - (@iPlanQty + @iLowerVDQty) = 0  --说明是下线补单
    BEGIN
        IF @CatchError = -1
        BEGIN
            UPDATE MFG_WO_List 
            SET 
                MesStatus = 2 
            WHERE 
                ErpWorkOrderNumber  = @WorkOrderNumber
            AND MesWorkOrderVersion = @iVersion
            AND(MesStatus = 0 OR MesStatus = 1 );
        END      
    END
     
    UPDATE MFG_WO_List 
    SET 
        MesCodeUBound = MesCodeUBound + 1 
    WHERE 
        ErpWorkOrderNumber  = @WorkOrderNumber
    AND MesWorkOrderVersion = 0 
    AND MesCodeUBound       = @iUbound; --此条件不可以省略, 事前我们没有对此表进行锁定操作, 这里防止多人同时生成同一个MES Code.

    IF @@ROWCOUNT = 0
    BEGIN
        SET @CatchError = 1;
        SET @RtnMsg = '此次生成失败, 可能是因为多人在同时使用同一订单生成MES码!';
        RETURN;
    END
    SET @sSerialNo = RIGHT('00000' + CONVERT(VARCHAR, @iUbound + 1), 4);
    SET @sDate  = FORMAT(GETDATE(), 'yyyyMMdd');
    SET @sLine  = '01';
    SET @CatchError = 0; 
    SET @MesCode = RIGHT(@WorkOrderNumber, 8) + @sDate + @sLine + @sSerialNo;
GO

--用以获得MES序列号值 此为测试时期使用的测试存储过程, 实施后即弃用.
--当前的编码规则为: 年月日 + 四位序列号
ALTER PROCEDURE [dbo].[usp_Mes_getMesCode]
AS
    DECLARE @MesCode        VARCHAR(50)
    DECLARE @SerialName     VARCHAR(50)
    DECLARE @SerialNumber   VARCHAR(15) 

    SET @SerialName    = FORMAT(GETDATE(), 'yyMMdd');
    EXEC usp_Mes_getNewSerialNo_Output @SerialName, 'RFID', 8, @SerialNumber OUTPUT
    SET @MesCode = @SerialName + RIGHT(@SerialNumber, 4);
    SELECT @MesCode AS MesCode;
GO

--用以获得序列号值, 如果当下要取得的序列不存在, 则新建立一个, 其值从1开始, 并且前导8个'0'值
--一般说来, 加入前导字符后, 整体序列号码不要超出12位长度.
ALTER PROCEDURE [dbo].[usp_Mes_getNewSerialNo]
    @SerialName     VARCHAR(50)  = '',  --序列号的系列名称,
    @SerialPrefix   VARCHAR(5)   = '',  --序列号的前导字符.一般情况, 建议三位字符串作为前导符.
    @SerialLength   INT          = 12   --序列号总体长度, 即已经包含最终序列号长度中的前导长度.最大不允许超过12位长度
AS

    IF @SerialLength > 12
    BEGIN
        SET @SerialLength  = 12;
    END

    BEGIN TRAN
    --判断序列号以及对应的前缀是否已经定义.
    IF 0 = ( SELECT COUNT(1)
             FROM Mes_SerialNoPoolList
             WHERE
                 SerialName   = @SerialName
             AND SerialPrefix = @SerialPrefix )
    BEGIN
        --新增一个独立前缀的系列号
        INSERT INTO Mes_SerialNoPoolList (SerialName,  SerialPrefix, SerialNo)
                              VALUES(@SerialName, @SerialPrefix, 0);
    END

    --更新缓冲池的数据, 新增一个序列号值
    UPDATE Mes_SerialNoPoolList
        SET SerialNo   = SerialNo + 1
           ,ModifyTime = GetDate()
    WHERE
            SerialName   = @SerialName
        AND SerialPrefix = @SerialPrefix;

    --返回新的序列号
    SELECT
        Upper(@SerialPrefix) + Right('00000000000' + Convert(VARCHAR, SerialNo), @SerialLength - LEN(@SerialPrefix)) AS SerialNo
    FROM Mes_SerialNoPoolList
    WHERE
            SerialName   = @SerialName
        AND SerialPrefix = @SerialPrefix;
    COMMIT

GO

--获取序列号的值, 其是以返回参数的形式完成的
ALTER PROCEDURE [dbo].[usp_Mes_getNewSerialNo_Output]
    @SerialName     VARCHAR(50)  = '',  --序列号的系列名称,
    @SerialPrefix   VARCHAR(5)   = '',  --序列号的前导字符.一般情况, 建议三位字符串作为前导符.
    @SerialLength   INT          = 12,  --序列号总体长度, 即已经包含最终序列号长度中的前导长度.最大不允许超过12位长度
    @SerialNumber   VARCHAR(15) OUTPUT  --把新的序列号值作为参数返回给调用者.
AS
    SET @SerialNumber = '';
    DECLARE @ListTB TABLE(SENO VARCHAR(15));
    INSERT INTO @ListTB
    EXEC [usp_Mes_getNewSerialNo] @SerialName, @SerialPrefix, @SerialLength
    SELECT @SerialNumber = SENO FROM @ListTB;
GO

--同步MES上传到SAP的完工报工状态
ALTER PROCEDURE [dbo].[usp_Mfg_Wo_List_Mes2Erp_ROC_UpdateStatus]
AS
    DECLARE     @RocId             AS INT
    DECLARE     @WoId              AS INT 
    DECLARE     @CfmStat           AS INT         


    DECLARE RecRoc CURSOR FOR
    SELECT ID, WOID, ErpCfmStatus
    FROM ERP_WO_REPORT_COMPLETE
    WHERE MesCfmStatus <> 3

    OPEN RecRoc;

    FETCH NEXT FROM RecRoc INTO @RocId, @WoId, @CfmStat;
    WHILE @@FETCH_STATUS = 0
    BEGIN
        BEGIN TRAN 
            UPDATE MFG_WO_List SET Mes2ErpCfmStatus = @CfmStat WHERE ID = @WoId;
            IF @CfmStat = 3
            BEGIN 
                UPDATE ERP_WO_REPORT_COMPLETE SET MesCfmStatus = 3 WHERE ID = @RocId;
            END
            ELSE
            BEGIN
                UPDATE ERP_WO_REPORT_COMPLETE SET MesCfmStatus = 1 WHERE ID = @RocId AND (MesCfmStatus = 0 OR MesCfmStatus = -1);
            END
        COMMIT
        FETCH NEXT FROM RecRoc INTO @RocId, @WoId, @CfmStat;
    END
    
    CLOSE RecRoc;
    DEALLOCATE RecRoc;
GO

--同步MES上传到SAP的计件物料扣除数量状态
ALTER PROCEDURE [dbo].[usp_Mfg_Wo_List_Mes2Erp_MVT_UpdateStatus]
AS
    DECLARE     @MvtId             AS INT
    DECLARE     @WoId              AS INT 
    DECLARE     @MvtStat           AS INT         


    DECLARE RecMvt CURSOR FOR
    SELECT ID, WOID, ErpMvtStatus
    FROM ERP_WO_Material_Transfer
    WHERE MesMvtStatus <> 3

    OPEN RecMvt;

    FETCH NEXT FROM RecMvt INTO @MvtId, @WoId, @MvtStat;
    WHILE @@FETCH_STATUS = 0
    BEGIN
        BEGIN TRAN 
            UPDATE MFG_WO_List SET Mes2ErpMVTStatus = @MvtStat WHERE ID = @WoId
            IF @MvtStat = 3
            BEGIN 
                UPDATE ERP_WO_Material_Transfer SET MesMvtStatus = 3 WHERE ID = @MvtId;
            END
            ELSE
            BEGIN
                UPDATE ERP_WO_Material_Transfer SET MesMvtStatus = 1 WHERE ID = @MvtId AND (MesMvtStatus = 0 OR MesMvtStatus = -1);
            END 
        COMMIT
        FETCH NEXT FROM RecMvt INTO @MvtId, @WoId, @MvtStat;
    END
    
    CLOSE RecMvt;
    DEALLOCATE RecMvt;
GO

ALTER PROCEDURE [dbo].[usp_Mfg_Wo_List_Erp2Mes_Import]
AS
    IF (SELECT ISNULL(MAX(ERP_ORDER_DETAIL), 0) FROM MES_CONFIG) <> 3 
    BEGIN
        RETURN;
    END

    DECLARE @RefreshTime AS DATETIME;
    SELECT @RefreshTime = MAX(MesCreateTime) FROM ERP_WO_List;

    IF DATEDIFF(MINUTE, @RefreshTime, GETDATE()) < 5 
    BEGIN
        RETURN;
    END
    
    BEGIN TRAN

    --(0):创建临时表
    CREATE TABLE #TMP_FULL (TMP_ID INT, MES_ID INT);
    
    CREATE TABLE #TMP_WO (
       [ID]                INT IDENTITY (1, 1) NOT NULL,                     -- (系统自动生成)
       [ErpWorkOrderNumber]    VARCHAR  (50)   NOT NULL,                     --订单编号
       [ErpGoodsCode]          VARCHAR  (50)   NOT NULL,                     --产品的物料编码
       [ErpGoodsDsca]          NVARCHAR (50)   NOT NULL,                     --产品的物料描述
       [ErpPlanQty]            INT             NOT NULL DEFAULT (0),         --计划产量
       [ErpPlanCreateTime]     DATETIME        NOT NULL,                     --计划创建时间
       [ErpPlanStartTime]      DATETIME        NOT NULL,                     --计划开始时间
       [ErpPlanFinishTime]     DATETIME        NOT NULL,                     --计划完成时间
       [ErpPlanReleaseTime]    DATETIME        NOT NULL,                     --计划发行时间
       [ErpWorkGroup]          VARCHAR  (15)   NOT NULL DEFAULT ('LNRT01'),  --生产线编号
       [ErpOrderType]          VARCHAR  (10)   NOT NULL DEFAULT (''),        --ERP订单类型
       [ErpOrderStatus]        VARCHAR  (50)   NOT NULL DEFAULT (''),        --ERP订单状态
       [ErpOBJNR]              VARCHAR  (30)   NOT NULL DEFAULT (''),        --对象号
       [ErpZTYPE]              VARCHAR  (30)   NOT NULL DEFAULT (''),        --订单类别
       [MesInturnNumber]       INT             NOT NULL DEFAULT (-1),        --生产排程顺序号,此处设置为-1,作为标志: 新增完成之后的统一调整为主表ID值.
       [MesPlanQty]            INT             NOT NULL DEFAULT (0),         --计划产量
       [MesPlanStartTime]      DATETIME            NULL,                     --计划开始时间
       [MesPlanFinishTime]     DATETIME            NULL,                     --计划完成时间
       [MesCostTime]           INT                 NULL DEFAULT (0),         --预计生产耗时(分钟)
       [MesUnitCostTime]       INT                 NULL DEFAULT (2)          --单位生产耗时(分钟)
    );
    
    --(1):插入ERP工单数据到临时表
    INSERT INTO #TMP_WO
    ([ErpWorkOrderNumber] ,[ErpGoodsCode] ,[ErpGoodsDsca] ,[ErpPlanQty] ,[ErpPlanCreateTime] ,[ErpPlanStartTime] ,[ErpPlanFinishTime] ,[ErpPlanReleaseTime] ,[ErpWorkGroup] ,[ErpOrderType] ,[ErpOrderStatus] ,[ErpOBJNR] ,[ErpZTYPE] ,[MesPlanQty] ,[MesPlanStartTime] ,[MesPlanFinishTime] ,[MesCostTime] ,[MesUnitCostTime] )
    SELECT
     RIGHT([AUFNR], 8), RIGHT([MATNR], 10), [MAKTX] ,[GAMNG] ,[ERDAT] ,[GSTRP] ,[GLTRP] ,[FTRMI] ,[WERKS] ,[AUART] ,[TXT30] ,[OBJNR] ,[ZTYPE] ,[GAMNG] ,[GSTRP] ,[GLTRP] ,[GAMNG] * 2 ,2
    FROM [ERP_WO_List] ERP
    WHERE
          DATEDIFF(DAY, GLTRP, GETDATE()) = 0
      AND MesCreateTime = @RefreshTime;
    
    --(2):插入产品物料编码表, 新增的产品料号自动添加进入 产品物料编码管理界面
    --此处原则上需要加入PLC参数复制代码, 可以直接调用存储过程来完成.
    DECLARE @GoodsCode          AS VARCHAR  (50); --产品的物料编码
    DECLARE @GoodsDsca          AS NVARCHAR (50); --产品的物料描述
    DECLARE @DimLength          AS INT          ; --长度(mm)
    DECLARE @DimHeight          AS INT          ; --高端(mm)
    DECLARE @DimWidth           AS INT          ; --宽度(mm)
    DECLARE @UnitCostTime       AS INT          ; --单位生产耗时(分钟)
    DECLARE @UpdateUser         AS NVARCHAR (50); --更新用户
    DECLARE @CatchError         AS INT          ; --系统判断用户操作异常的数量
    DECLARE @RtnMsg             AS NVARCHAR(100); --返回状态
    DECLARE RECGOODS CURSOR FOR
                  SELECT DISTINCT ErpGoodsCode, ErpGoodsDsca, 120, 20, 120, 2, 'ERP_MES', 0, ''
                  FROM #TMP_WO
                  LEFT JOIN Mes_Goods_List ON #TMP_WO.ErpGoodsCode = Mes_Goods_List.GoodsCode
                  WHERE Mes_Goods_List.GoodsDsca IS NULL;  --此处之所以是这种写法而没有使用NOT IN 语句是考虑到效率问题.
    
    OPEN RECGOODS;
    FETCH NEXT FROM RECGOODS INTO @GoodsCode, @GoodsDsca, @DimLength, @DimHeight, @DimWidth, @UnitCostTime, @UpdateUser, @CatchError, @RtnMsg;
    WHILE @@FETCH_STATUS = 0
    BEGIN
        EXEC usp_Mes_Goods_List_Add   @GoodsCode, @GoodsDsca, @DimLength, @DimHeight, @DimWidth, @UnitCostTime, @UpdateUser, @CatchError, @RtnMsg;
        FETCH NEXT FROM RECGOODS INTO @GoodsCode, @GoodsDsca, @DimLength, @DimHeight, @DimWidth, @UnitCostTime, @UpdateUser, @CatchError, @RtnMsg;
    END
    CLOSE RECGOODS;
    DEALLOCATE RECGOODS;

    --(3):更新临时表的 MesCostTime, MesUnitCostTime    
    UPDATE #TMP_WO
    SET
       MesCostTime     = #TMP_WO.MesPlanQty * Mes_Goods_List.UnitCostTime
      ,MesUnitCostTime = Mes_Goods_List.UnitCostTime
    FROM Mes_Goods_List
    WHERE #TMP_WO.ErpGoodsCode = Mes_Goods_List.GoodsCode;
    
    --(4):进行全连接, 目的是找出新增的或者是待删除掉的订单ID    
    INSERT INTO #TMP_FULL (TMP_ID, MES_ID)
    SELECT #TMP_WO.ID, MFG_WO_List.ID
    FROM
        #TMP_WO
        FULL JOIN 
    (SELECT MFG_WO_List.ID, MFG_WO_List.ErpWorkOrderNumber
    FROM MFG_WO_List
    WHERE 
    DATEDIFF(DAY, MFG_WO_List.ErpPlanStartTime, GETDATE()) = 0
              AND MFG_WO_List.MesWorkOrderVersion = 0
              AND MFG_WO_List.MesWorkOrderType    = 0
              ) AS MFG_WO_List ON #TMP_WO.ErpWorkOrderNumber = MFG_WO_List.ErpWorkOrderNumber;
          --注意:这里使用的是ERPPlan Date, 避免在MES中把排程时间推迟或提前而影响判断
    
    --(5.1):插入新的订单记录到表:Mfg_WO_List
    INSERT INTO Mfg_WO_List
    ([ErpWorkOrderNumber] ,[ErpGoodsCode] ,[ErpGoodsDsca] ,[ErpPlanQty] ,[ErpPlanCreateTime] ,[ErpPlanStartTime] ,[ErpPlanFinishTime] ,[ErpPlanReleaseTime] ,[ErpWorkGroup] ,[ErpOrderType] ,[ErpOrderStatus] ,[ErpOBJNR] ,[ErpZTYPE] ,[MesInturnNumber] ,[MesPlanQty] ,[MesPlanStartTime] ,[MesPlanFinishTime] ,[MesCostTime] ,[MesUnitCostTime] ,MesCustomerID)
     SELECT
     [ErpWorkOrderNumber] ,[ErpGoodsCode] ,[ErpGoodsDsca] ,[ErpPlanQty] ,[ErpPlanCreateTime] ,[ErpPlanStartTime] ,[ErpPlanFinishTime] ,[ErpPlanReleaseTime] ,[ErpWorkGroup] ,[ErpOrderType] ,[ErpOrderStatus] ,[ErpOBJNR] ,[ErpZTYPE] ,[MesInturnNumber] ,[MesPlanQty] ,[MesPlanStartTime] ,[MesPlanFinishTime] ,[MesCostTime] ,[MesUnitCostTime] ,1
     FROM #TMP_WO
     WHERE ID IN (SELECT TMP_ID FROM #TMP_FULL WHERE TMP_ID IS NOT NULL AND MES_ID IS NULL);

    --(5.2):导入用料数据到表:Mfg_WO_MTL_List
    INSERT INTO MFG_WO_MTL_List
    ([CommentReqNumber] ,[CommentReqPosition] ,[WorkOrderNumber] ,[LineNumber] ,[ItemNumber] ,[ItemDsca] ,[Qty] ,[UOM] ,[ProcessCode] ,[WorkCenter] ,[WcDsca] ,[WHLocation] ,[Phantom] ,[Bulk] ,[Backflush] ,[WorkSite], [MesCreateUser], [MesModifyUser])
    SELECT
     MTL.RSNUM ,MTL.RSPOS, RIGHT(MTL.AUFNR, 8), MTL.POSNR , RIGHT(MTL.MATNR, 10) ,MTL.MAKTX ,MTL.ERFMG ,MTL.ERFME ,MTL.VORNR ,MTL.ARBPL ,MTL.KTEXT ,MTL.LGORT ,MTL.DUMPS ,MTL.SCHGT ,MTL.RGEKZ ,MTL.WERKS, 'MES_SYS', ''
    FROM
        ERP_WO_MTL_List MTL,
        #TMP_WO WO
    WHERE
           RIGHT(MTL.AUFNR, 8) = WO.ErpWorkOrderNumber
       AND WO.ID IN (SELECT TMP_ID FROM #TMP_FULL WHERE TMP_ID IS NOT NULL AND MES_ID IS NULL)
       --此条件, 最好不要去掉, 这样可以保证SAP多次更新的时候不至于串皮, 此处取了一个中间折扣: 相差不超过1分钟的可以接受
       --为了确保订单的用料数据能够顺利导入不缺失, 在刷新导入MES正式表的时候, 故意后延了5分钟时间用以保证其数据导入完全, 因此不必[需要重写]
       AND ABS(DATEDIFF(MINUTE, MTL.MesCreateTime , @RefreshTime)) <= 1; 

    --(6.1):删除Mfg_WO_List表中在SAP中删除的订单的用料数据
    DELETE MTL
    FROM MFG_WO_MTL_List MTL
    INNER JOIN MFG_WO_LIST WO ON
            MTL.WorkOrderNumber  = WO.ErpWorkOrderNumber
        AND MTL.WorkOrderVersion = WO.MesWorkOrderVersion
    WHERE
          WO.MesStatus = 0
      AND WO.ID IN (SELECT MES_ID FROM #TMP_FULL WHERE TMP_ID IS NULL AND MES_ID IS NOT NULL);

    --(6.2):删除Mfg_WO_List表中在SAP中删除的订单
    DELETE
    FROM MFG_WO_List
    WHERE
       MesStatus = 0
       AND ID IN (SELECT MES_ID FROM #TMP_FULL WHERE TMP_ID IS NULL AND MES_ID IS NOT NULL);
  
    --(5)(6)处理真值表
    -- ┌------------------------------┐
    -- | TMP_ID | MES_ID |  Operation |
    -- |--------+--------+------------|
    -- |   V    |   V    |    --      |
    -- |--------+--------+------------|
    -- |   V    |   --   |   INSERT   |
    -- |--------+--------+----------- |
    -- |   --   |   V    |   DELETE   |
    -- |--------+--------+----------- |
    -- |   --   |   --   |    --      |
    -- └------------------------------┘
  
    --(7):调整新增进来的生产排程顺序  
    UPDATE MFG_WO_List
    SET MesInturnNumber = ID
    WHERE MesInturnNumber = -1;
  
    DROP TABLE #TMP_FULL;
    DROP TABLE #TMP_WO;
  
    COMMIT;
GO

--更新物料拉动响应是否超时标志.
ALTER PROCEDURE  [dbo].[usp_Mfg_Wo_Mtl_Pull_Update_OTFlag]
AS
    UPDATE MFG_WO_MTL_Pull 
    SET MFG_WO_MTL_Pull.OTFlag = 1    
    FROM 
    MFG_WO_MTL_Pull MTL
    LEFT JOIN Mes_Threshold_List HH on MTL.ItemNumber = HH.ItemNumber 
    WHERE 
         MTL.Status = 0
     AND MTL.OTFlag = 0
     AND DATEDIFF(MINUTE, MTL.PullTime , GETDATE()) - ISNULL(HH.MinTrigQty,30) > 0
GO

-- PLC 触发了动作
ALTER PROCEDURE  [dbo].[usp_Mfg_Plc_Trig]
      @TagName            AS VARCHAR  (50)       -- PLC的Tag名称, 形如: LN01.CP01.AlarmBool09
     ,@TagValue           AS VARCHAR  (50) = ''  -- PLC的Tag值, 形如: True
     ,@ProcessCode        AS VARCHAR  (50) = ''  -- 工序编号, 形如: 1010
AS
    DECLARE @ApplModel AS VARCHAR(10);

    SET @ApplModel = '';

    SELECT 
         @ApplModel   = Mes_PLC_Parameters.ApplModel
        ,@ProcessCode = Mes_PLC_Parameters.ProcessCode
    FROM 
        Mes_PLC_Parameters, Mes_PLC_List 
    WHERE 
        Mes_PLC_Parameters.PLCID = Mes_PLC_List.ID
    AND Mes_PLC_Parameters.ParamName = @TagName 
    AND Mes_PLC_List.GoodsCode = '0000000000';
    
    INSERT Log_Mfg_Plc_Tag_Trig (TagName, TagValue, ProcessCode, Category) VALUES(@TagName, @TagValue, @ProcessCode, ISNULL(@ApplModel,''));

    IF @ApplModel = 'ET' --能源计数触发
    BEGIN
        EXEC [usp_Mfg_Plc_Trig_ET] @TagName, @TagValue, @ProcessCode; RETURN;
    END

    IF @ApplModel = 'MT' --物料拉动触发
    BEGIN
        EXEC [usp_Mfg_Plc_Trig_MT] @TagName, @TagValue, @ProcessCode; RETURN;
    END

    IF @ApplModel = 'QT' --产量计数触发
    BEGIN
        EXEC [usp_Mfg_Plc_Trig_QT] @TagName, @TagValue, @ProcessCode; RETURN;
    END

    IF @ApplModel = 'CT' --产品变更完成触发
    BEGIN
        EXEC [usp_Mfg_Plc_Trig_CT] @TagName, @TagValue, @ProcessCode; RETURN;
    END
GO

-- PLC 触发了 产品变更完成触发 动作
ALTER PROCEDURE  [dbo].[usp_Mfg_Plc_Trig_CT]
      @TagName            AS VARCHAR  (50)       
     ,@TagValue           AS VARCHAR  (50) = ''  
     ,@ProcessCode        AS VARCHAR  (50) = ''  
AS
    --当MES 给PLC 发送变更请求是 1 触发对话框出现, 操作员如果点击了确认, 则此标记会变为 0 值.
    IF @TagValue = '1'
    BEGIN
        RETURN; 
    END

    --完成Process记录点的工单切换动作: 正在生产的工单值使用将下一工单的工单值覆盖. 并且将下一工单值置空.
    UPDATE Mes_Process_List
    SET 
         WorkOrderNumber      = PLS.NextWorkOrderNumber
        ,WorkOrderVersion     = PLS.NextWorkOrderVersion
        ,PlanQty              = WO.MesPlanQty
        ,NextWorkOrderNumber  = ''
        ,NextWorkOrderVersion = -1
    FROM 
        Mes_Process_List PLS
       ,MFG_WO_List      WO
    WHERE
         PLS.NextWorkOrderNumber  = WO.ErpWorkOrderNumber  
     AND PLS.NextWorkOrderVersion = WO.MesWorkOrderVersion 
     AND PLS.ProcessCode          = @ProcessCode;
GO

-- PLC 触发了 能源计数 动作
ALTER PROCEDURE  [dbo].[usp_Mfg_Plc_Trig_ET]
      @TagName            AS VARCHAR  (50)       
     ,@TagValue           AS VARCHAR  (50) = ''  
     ,@ProcessCode        AS VARCHAR  (50) = ''  
AS
    DECLARE @PreValue AS INT;
    SELECT @PreValue = ISNULL((SELECT DisplayValue FROM Mes_Energy_Record WHERE ID = (SELECT MAX(ID) FROM Mes_Energy_Record)), 0);
    INSERT INTO Mes_Energy_Record 
           (DisplayValue,            CostValue)
    VALUES (CONVERT(INT, @TagValue), CONVERT(INT, @TagValue) - @PreValue);
GO

ALTER PROCEDURE [dbo_Mfg_Plc_Trig_MT_Require]
     @TagName            AS VARCHAR (50) 
    ,@ProcessCode        AS VARCHAR (50)
    ,@WorkOrderNumber    AS VARCHAR (50)
    ,@WorkOrderVersion   AS INT
    ,@WorkOrderStatus    AS INT             OUTPUT
    ,@GoodsCode          AS VARCHAR (50)    OUTPUT
    ,@MesPlanQty         AS INT             OUTPUT
    ,@ActionQty          AS NUMERIC (18, 4) OUTPUT
    ,@RequireQty         AS NUMERIC (18, 4) OUTPUT
    ,@ThresholdQty       AS NUMERIC (18, 4) OUTPUT
    ,@ItemNumber         AS VARCHAR (50)    OUTPUT
    ,@UOM                AS NVARCHAR(15)    OUTPUT
    ,@ItemDsca           AS NVARCHAR(50)    OUTPUT
    ,@WaitingResponse    AS INT             OUTPUT
    ,@BkfMTLFlag         AS INT             OUTPUT
    ,@MubPercent         AS NUMERIC (18, 4) OUTPUT
AS
    --找到工单的状态, 产品, 计划产量
    SELECT 
         @WorkOrderStatus = MesStatus
        ,@GoodsCode       = ErpGoodsCode
        ,@MesPlanQty      = MesPlanQty
    FROM MFG_WO_List
    WHERE
         ErpWorkOrderNumber  = @WorkOrderNumber
     AND MesWorkOrderVersion = @WorkOrderVersion;

    --得到需要拉动的物料
    SELECT
        @ItemNumber = Mes_PLC_Parameters.ItemNumber
    FROM 
        Mes_PLC_Parameters
       ,Mes_PLC_List 
    WHERE 
        Mes_PLC_Parameters.PLCID     = Mes_PLC_List.ID
    AND Mes_PLC_List.GoodsCode       = @GoodsCode
    AND Mes_PLC_Parameters.ParamName = @TagName
    AND Mes_PLC_Parameters.ApplModel = 'MT';

    --得到本工单已经拉动物料数量(可能是包含了未确认的, 但是已经响应了的数量)
    SELECT 
         @ActionQty       = ISNULL(SUM(ActionQty), 0)
        ,@WaitingResponse = ISNULL(SUM(CASE [Status] WHEN 0 THEN 1 ELSE 0 END), 0)
    FROM
        MFG_WO_MTL_Pull
    WHERE 
         WorkOrderNumber   = @WorkOrderNumber
     AND WorkOrderVersion  = @WorkOrderVersion
     AND ItemNumber        = @ItemNumber
     AND ProcessCode       = @ProcessCode
     AND [Status]         >= 0;
  
    --得到本工位的对应的物料的用量比例(%), 如果不存在则会默认值为100%.
    SELECT @MubPercent = MubPercent 
    FROM Mes_Mub_List 
    WHERE
        GoodsCode   = @GoodsCode
    AND ItemNumber  = @ItemNumber
    AND ProcessCode = @ProcessCode;
    
    SELECT @MubPercent = ISNULL(@MubPercent, 100.0);

    --得到本工单对应此种物料的需求数量
    SELECT 
        @RequireQty = ISNULL(SUM(Qty), 0) * @MubPercent/100
    FROM
        MFG_WO_MTL_List
    WHERE 
         WorkOrderNumber  = @WorkOrderNumber
     AND WorkOrderVersion = @WorkOrderVersion
     AND ItemNumber       = @ItemNumber;  

    --得到本物料的物料拉动阈值.
    SELECT 
        @ThresholdQty = ISNULL(MaxPullQty,100)
       ,@UOM          = ISNULL(UOM,      'EA')
       ,@ItemDsca     = ISNULL(ItemName,  '' )
    FROM
        Mes_Threshold_List
    WHERE
        ItemNumber = @ItemNumber; 

    IF @ThresholdQty IS NULL SET @ThresholdQty  = 100;
    IF @UOM          IS NULL SET @UOM           = 'EA';
    IF @ItemDsca     IS NULL SET @ItemDsca      = 'MES系统的物料阈值管理尚未维护描述';

    SELECT 
        @BkfMTLFlag = COUNT(1) 
    FROM 
        MFG_WIP_BKF_Item_List
    WHERE 
        ItemNumber = @ItemNumber;

GO

--获取物料拉动当下的物料拉动工单清单
ALTER PROCEDURE  [dbo].[usp_Mfg_Plc_Param_WO_List]
AS
    SELECT 
        PAM.*,
        WOL.ErpGoodsCode GoodsCode,
        WOL.ErpGoodsDsca GoodsDsca,
        WOL.MesWorkOrderType WorkOrderType
    FROM 
        Mes_PLC_Parameters AS PAM 
    INNER JOIN Mes_PLC_List AS PLC ON PAM.PLCID = PLC.ID
    LEFT JOIN MFG_WO_List  WOL ON PAM.WorkOrderNumber = WOL.ErpWorkOrderNumber and PAM.WorkOrderVersion = WOL.MesWorkOrderVersion
    WHERE
         PAM.ApplModel = 'MT'
     AND PLC.GoodsCode = '0000000000'
    ORDER BY 
        PAM.ProcessCode
       ,PAM.ParamName 
GO

--更新PLC参数表的当下正在物料拉动物料的工单.
ALTER PROCEDURE  [dbo].[usp_Mfg_Plc_Param_WO_Update]
     @TagName            AS VARCHAR (50) = ''
    ,@WorkOrderNumber    AS VARCHAR (50) = ''
    ,@WorkOrderVersion   AS INT          = -1
AS
 UPDATE Mes_Plc_Parameters
            SET    
                WorkOrderNumber  = @WorkOrderNumber              
               ,WorkOrderVersion = @WorkOrderVersion            
            FROM 
                Mes_PLC_Parameters
               ,Mes_PLC_List 
            WHERE 
                Mes_PLC_Parameters.PLCID     = Mes_PLC_List.ID
            AND Mes_PLC_List.GoodsCode       = '0000000000'
            AND Mes_PLC_Parameters.ApplModel = 'MT'
            AND Mes_PLC_Parameters.ParamName = @TagName;
GO

--更新PLC参数表的当下正在物料拉动物料的工单(使用ID值作为限制条件).
ALTER PROCEDURE  [dbo].[usp_Mfg_Plc_Param_WO_UpdateById]
     @WoId               AS INT = 0
    ,@ParamId            AS INT = 0
    ,@CatchError         AS INT           OUTPUT --系统判断用户操作异常的数量
    ,@RtnMsg             AS NVARCHAR(100) OUTPUT --返回值
AS
    SET @CatchError = 0
    SET @RtnMsg     = '';

    UPDATE Mes_Plc_Parameters
    SET    
        WorkOrderNumber  = Mfg_WO_List.ErpWorkOrderNumber              
       ,WorkOrderVersion = Mfg_WO_List.MesWorkOrderVersion            
    FROM 
        Mes_PLC_Parameters
       ,Mfg_WO_List
    WHERE 
       (   @ParamId <> -1 AND Mes_PLC_Parameters.ID = @ParamId   
        OR @ParamId =  -1 AND Mes_PLC_Parameters.PLCID IN ( SELECT ID 
                                                            FROM Mes_PLC_List 
                                                            WHERE 
                                                                GoodsCode                    = '0000000000' 
                                                            AND Mes_PLC_Parameters.ApplModel = 'MT'
                                                           ) 
       )
    AND Mfg_WO_List.ID = @WoId;
GO

--更新Mes_Process_List表的在产工单和待产工单.
ALTER PROCEDURE  [dbo].usp_Mfg_Process_List_WO_UpdateById
     @WoId               AS INT = 0
    ,@ProcId             AS INT = 0
    ,@OPtype             AS VARCHAR (50) = ''
    ,@CatchError         AS INT           OUTPUT --系统判断用户操作异常的数量
    ,@RtnMsg             AS NVARCHAR(100) OUTPUT --返回值
AS
    SET @CatchError = 0
    SET @RtnMsg     = '';

    UPDATE Mes_Process_List
    SET    
        WorkOrderNumber      = CASE WHEN @OPtype = 'CURR' OR @OPtype='CURRALL' THEN Mfg_WO_List.ErpWorkOrderNumber  ELSE Mes_Process_List.WorkOrderNumber      END
       ,WorkOrderVersion     = CASE WHEN @OPtype = 'CURR' OR @OPtype='CURRALL' THEN Mfg_WO_List.MesWorkOrderVersion ELSE Mes_Process_List.WorkOrderVersion     END
       ,NextWorkOrderNumber  = CASE WHEN @OPtype = 'NEXT' OR @OPtype='NEXTALL' THEN Mfg_WO_List.ErpWorkOrderNumber  ELSE Mes_Process_List.NextWorkOrderNumber  END
       ,NextWorkOrderVersion = CASE WHEN @OPtype = 'NEXT' OR @OPtype='NEXTALL' THEN Mfg_WO_List.MesWorkOrderVersion ELSE Mes_Process_List.NextWorkOrderVersion END

    FROM 
        Mfg_WO_List
    WHERE 
       (Mes_Process_List.ID = @ProcId OR @OPtype='CURRALL' OR @OPtype='NEXTALL' ) 
    AND Mfg_WO_List.ID = @WoId;
GO


-- PLC 触发了 物料拉动 动作
ALTER PROCEDURE  [dbo].[usp_Mfg_Plc_Trig_MT]
      @TagName                AS VARCHAR  (50)       
     ,@TagValue               AS VARCHAR  (50) = ''  
     ,@ProcessCode            AS VARCHAR  (50) = ''
     ,@PullUser               AS NVARCHAR (50) = N'MES'  
AS
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

    DECLARE @BkfMTLFlag           AS INT;         --要拉动的物料是否为反冲料标志: 0:不是反冲料; >0: 是反冲料.
    DECLARE @MubPercent           AS NUMERIC (18, 4); --多个工位共享料的物料用量比例(%).


    IF UPPER(@TagValue) = 'FALSE' OR UPPER(@TagValue) = '0'
    BEGIN
        --仅仅响应触发值为'TRUE' 或 '1' 的值.
        RETURN;
    END

    --1.查找工序清单, 找到当下的工单, 

    --查找工序, 工单(此处可能产生的记录数多余一个, 但我们只取最后一条记录的值)
    SELECT 
        @WorkOrderNumber  = WorkOrderNumber
       ,@WorkOrderVersion = WorkOrderVersion
       ,@ProcessCode      = Mes_PLC_Parameters.ProcessCode
    FROM 
        Mes_PLC_Parameters
       ,Mes_PLC_List
    WHERE 
        Mes_PLC_Parameters.PLCID     = Mes_PLC_List.ID
    AND Mes_PLC_List.GoodsCode       = '0000000000'
    AND Mes_PLC_Parameters.ApplModel = 'MT'
    AND Mes_PLC_Parameters.ParamName = @TagName;

    --如果工单为空, 则需要进行一下初始化
    IF ISNULL(@WorkOrderNumber, '') = ''
    BEGIN
        SELECT @WorkOrderNumber = '', @WorkOrderVersion = -1;
        EXEC [usp_Mfg_Wo_List_get_Next_Available] @WorkOrderNumber OUTPUT, @WorkOrderVersion OUTPUT; 
        EXEC [usp_Mfg_Plc_Param_WO_Update] @TagName, @WorkOrderNumber, @WorkOrderVersion;
    END

    IF ISNULL(@WorkOrderNumber, '') = ''
    BEGIN
        --说明当下没有排程计划. 此时直接返回
        RETURN;
    END 

    EXEC [dbo_Mfg_Plc_Trig_MT_Require] @TagName, @ProcessCode, @WorkOrderNumber, @WorkOrderVersion, @WorkOrderStatus OUTPUT, @GoodsCode OUTPUT, @MesPlanQty OUTPUT, @ActionQty OUTPUT, @RequireQty OUTPUT, @ThresholdQty OUTPUT, @ItemNumber OUTPUT, @UOM OUTPUT, @ItemDsca OUTPUT, @WaitingResponse OUTPUT, @BkfMTLFlag OUTPUT, @MubPercent OUTPUT;

    --反冲料, 只依据于阈值管理的数量进行物料的数量拉动, 并且其他各种条件均不考虑.
    IF @BkfMTLFlag > 0 
    BEGIN
        SELECT @ApplyQty             = @ThresholdQty
              ,@WorkOrderNumber      = ''
              ,@WorkOrderVersion     = 0
              ,@NextWorkOrderNumber  = ''
              ,@NextWorkOrderVersion = 0
              ,@NextWOPlanQty        = 0
              ,@ActionQty            = 0;
    END
    ELSE
    BEGIN
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
            EXEC [usp_Mfg_Plc_Param_WO_Update] @TagName, @WorkOrderNumber, @WorkOrderVersion;
            EXEC [dbo_Mfg_Plc_Trig_MT_Require] @TagName, @ProcessCode, @WorkOrderNumber, @WorkOrderVersion, @WorkOrderStatus OUTPUT, @GoodsCode OUTPUT, @MesPlanQty OUTPUT, @ActionQty OUTPUT, @RequireQty OUTPUT, @ThresholdQty OUTPUT, @ItemNumber OUTPUT, @UOM OUTPUT, @ItemDsca OUTPUT, @WaitingResponse OUTPUT, @BkfMTLFlag OUTPUT, @MubPercent OUTPUT;

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

        --取得下一工单的相应信息.
        SELECT @NextWorkOrderNumber = @WorkOrderNumber, @NextWorkOrderVersion = @WorkOrderVersion;
        EXEC [usp_Mfg_Wo_List_get_Next_Available] @NextWorkOrderNumber OUTPUT, @NextWorkOrderVersion OUTPUT;

        SELECT @NextWOPlanQty = ISNULL(MesPlanQty, 0)
        FROM MFG_WO_List
        WHERE
                ErpWorkOrderNumber  = @NextWorkOrderNumber
            AND MesWorkOrderVersion = @NextWorkOrderVersion;
        
        --如果当下工单的状态为"待生产", 则需要设置工单为"产前调整中",
        IF @WorkOrderStatus = 0 
        BEGIN
            UPDATE MFG_WO_List 
            SET 
                MesStatus = 1 
            WHERE
                ErpWorkOrderNumber  = @WorkOrderNumber
            AND MesWorkOrderVersion = @WorkOrderVersion
            AND MesStatus           = 0; --此条件不可以省略, 因为我们是提前获取状态的时候, 当时并没有为表加锁.
        END
    END 
    --产生物料拉料动作.
    INSERT INTO MFG_WO_MTL_Pull 
          ( WorkOrderNumber,   WorkOrderVersion,  NextWorkOrderNumber,  NextWorkOrderVersion,  NextWOPlanQty,  ActionTotalQty,  ItemNumber,  ItemDsca,  ProcessCode,  UOM,  Qty,       PullUser )
    VALUES( @WorkOrderNumber, @WorkOrderVersion, @NextWorkOrderNumber, @NextWorkOrderVersion, @NextWOPlanQty, @ActionQty,      @ItemNumber, @ItemDsca, @ProcessCode, @UOM, @ApplyQty, @PullUser );

    --产生物料拉料动作-绑定的附属料.
    INSERT INTO MFG_WO_MTL_Pull 
          ( WorkOrderNumber,  WorkOrderVersion,  NextWorkOrderNumber,  NextWorkOrderVersion,  NextWOPlanQty,  ActionTotalQty,        ItemNumber,  ItemDsca,  ProcessCode,  UOM,  Qty,                  PullUser )
    SELECT @WorkOrderNumber, @WorkOrderVersion, @NextWorkOrderNumber, @NextWorkOrderVersion, @NextWOPlanQty, @ActionQty * RatioQty,  ItemNumber,  ItemDsca, @ProcessCode, @UOM, @ApplyQty * RatioQty, @PullUser 
    FROM Mes_Mtl_Pull_Item_Attached
    WHERE 
         GoodsCode = @GoodsCode
     AND MainItem  = @ItemNumber;

    --(需要判断当前是否为全局"暂停/正常"标志, 此处涉及到异常恢复情况场景, 比较复杂, 时间关系不考虑)
GO

-- PLC 触发了 产量计数 动作
ALTER PROCEDURE  [dbo].[usp_Mfg_Plc_Trig_QT]
      @TagName            AS VARCHAR  (50)       
     ,@TagValue           AS VARCHAR  (50) = ''  
     ,@ProcessCode        AS VARCHAR  (50) = ''  
AS
    DECLARE @ProcessFinishQty   AS INT;
    DECLARE @WorkOrderNumber    AS VARCHAR (50);
    DECLARE @WorkOrderVersion   AS INT;
    DECLARE @WorkOrderStatus    AS INT;
    DECLARE @GoodsCode          AS VARCHAR (50);
    DECLARE @TagFinishQty       AS INT;

    SET @TagFinishQty = CONVERT(INT, @TagValue);

   --共需要3步操作: 
    --1.查找工序清单, 找到当下的工单, 

    --如果决定结束工单需要从码垛工位的计数机制来完成, 则需要修改此处的工单号取得方式(仅仅多查看一下TAG标识表的时时值即可得到)
    --而且仅仅需要在@FinalFlag = 1的情况的工位下有此差别, 其它工位可以认为没有差别, 那些记录的数据都是为了记录日志和制作报告而维护着.
    --此处[需要重写]
    --查找工单

    SELECT 
         @WorkOrderNumber  = WorkOrderNumber
        ,@WorkOrderVersion = WorkOrderVersion
        ,@ProcessFinishQty = FinishQty
    FROM Mes_Process_List 
    WHERE ProcessCode = @ProcessCode;  --可以统一都使用PLC参数的ProcessCode, 也便于记忆和理解, 也许适用性更强些.


    --如果订单已经完结, 则找到当下排程的下一个工单
    --工序订单状态的变更, 已经不在此处来完成了, 其是使用CS(产品变更)完成信号的触发来进行和下一个订单翻转完成的机制[2017-09-21]
    --IF ISNULL(@ProcessFinishQty, -1) = -1
    --BEGIN
    --    --如果工单为空, 则需要进行一下初始化
    --    IF ISNULL(@WorkOrderNumber, '') = ''
    --    BEGIN
    --        SELECT @WorkOrderNumber = '', @WorkOrderVersion = -1;
    --    END
    --    EXEC [usp_Mfg_Wo_List_get_Next_Available] @WorkOrderNumber OUTPUT, @WorkOrderVersion OUTPUT; 
    --END


    IF ISNULL(@WorkOrderNumber, '') = ''
    BEGIN
        --说明当下没有排程计划. 此时直接返回
        RETURN;
    END 

    --记录节拍数据
    DECLARE @PreValue AS DATETIME;
    SELECT @PreValue = ISNULL(
            (
                SELECT UpdateTime 
                FROM Mes_Process_Beat_Record 
                WHERE ID = (SELECT MAX(ID) FROM Mes_Process_Beat_Record WHERE TagName = @TagName)
            ),     
            GETDATE()
        );

    INSERT INTO Mes_Process_Beat_Record 
           ( ProcessCode,  WorkOrderNumber,  WorkOrderVersion,  TagName,  DisplayValue, BeatValue)
    VALUES (@ProcessCode, @WorkOrderNumber, @WorkOrderVersion, @TagName, @TagFinishQty,  DATEDIFF(SECOND, @PreValue, GETDATE()));

    DECLARE @MesPlanQty       INT = 0; --原始订单计划数量
    DECLARE @PrsPlanQty       INT = 0; --Process计划数量
                                 
    DECLARE @selfDiscardQty1  INT = 0; --本订单报废数量
    DECLARE @selfDiscardQty2  INT = 0; --本订单报废数量
    DECLARE @selfDiscardQty3  INT = 0; --本订单报废数量
    DECLARE @selfDiscardQty4  INT = 0; --本订单报废数量
                                  
    DECLARE @selfLeftQty1     INT = 0; --本订单待修数量
    DECLARE @selfLeftQty2     INT = 0; --本订单待修数量
    DECLARE @selfLeftQty3     INT = 0; --本订单待修数量
    DECLARE @selfLeftQty4     INT = 0; --本订单待修数量
                                  
    DECLARE @baseDiscardQty1  INT = 0; --母订单报废数量
    DECLARE @baseDiscardQty2  INT = 0; --母订单报废数量
    DECLARE @baseDiscardQty3  INT = 0; --母订单报废数量
    DECLARE @baseDiscardQty4  INT = 0; --母订单报废数量
                                 
    DECLARE @baseLeftQty1     INT = 0; --母订单待修数量
    DECLARE @baseLeftQty2     INT = 0; --母订单待修数量
    DECLARE @baseLeftQty3     INT = 0; --母订单待修数量
    DECLARE @baseLeftQty4     INT = 0; --母订单待修数量
                                  
    DECLARE @AbnormalRegion   INT = 0;
    DECLARE @FinalFlag        INT = 0;
    DECLARE @StartFlag        INT = 0;
    DECLARE @FinishQty        INT = 0;    

    --取得本工序的基本配置信息
    SELECT 
         @AbnormalRegion = AbnormalRegion
        ,@FinalFlag      = FinalFlag 
        ,@StartFlag      = StartFlag
    FROM Mes_Process_List
    WHERE 
        ProcessCode = @ProcessCode
    
    --取得本订单的信息,状态
    SELECT
         @MesPlanQty      = MesPlanQty        
        ,@selfDiscardQty1 = MesDiscardQty1
        ,@selfDiscardQty2 = MesDiscardQty2
        ,@selfDiscardQty3 = MesDiscardQty3
        ,@selfDiscardQty4 = MesDiscardQty4
        ,@selfLeftQty1    = MesLeftQty1
        ,@selfLeftQty2    = MesLeftQty2
        ,@selfLeftQty3    = MesLeftQty3
        ,@selfLeftQty4    = MesLeftQty4
        ,@WorkOrderStatus = MesStatus
        ,@GoodsCode       = ErpGoodsCode
    FROM
         MFG_WO_List
    WHERE
        ErpWorkOrderNumber  = @WorkOrderNumber
    AND MesWorkOrderVersion = @WorkOrderVersion;

    IF @AbnormalRegion >= 0
    BEGIN
        SET @FinishQty = @TagFinishQty; 
    END
 
    IF @AbnormalRegion >= 1
    BEGIN
        SET @FinishQty = @FinishQty + @selfDiscardQty1 + @selfLeftQty1;
    END
    
    IF @AbnormalRegion >= 2
    BEGIN
        SET @FinishQty = @FinishQty + @selfDiscardQty2 + @selfLeftQty2;
    END

    IF @AbnormalRegion >= 3
    BEGIN
        SET @FinishQty = @FinishQty + @selfDiscardQty3 + @selfLeftQty3;
    END

    IF @AbnormalRegion >= 4
    BEGIN
        SET @FinishQty = @FinishQty + @selfDiscardQty4 + @selfLeftQty4;
    END

    IF @AbnormalRegion >= 0
    BEGIN
        SET @FinishQty = @FinishQty + 0;
    END

  ------------ 为了调试存储过程而临时加入的这一段记录中间值, 便于分析.
  --  INSERT INTO [dbo].[Log_QT_List] 
  --         ( ProcessCode,  WorkOrderNumber,  WorkOrderVersion,  FinishQty,  PlanQty,   Comment)
  --  VALUES (@ProcessCode, @WorkOrderNumber, @WorkOrderVersion, @FinishQty, @PrsPlanQty, 
  --    ''
  --  + 'TagName;'   + @TagName  + ';'
  --  + 'TagValue;'  + @TagValue + ';'
  --  + 'Region;'    + convert(varchar, @AbnormalRegion) + ';'
  --  + 'WOStatus;'  + convert(varchar, @WorkOrderStatus) + ';'
  --  + 'FinalFlag;' + convert(varchar, @FinalFlag) + ';'
  --  + 'StartFlag;' + convert(varchar, @StartFlag) + ';'
  ----  + 'DiscQty1;'  + convert(varchar, @selfDiscardQty1) + ';'
  ----  + 'DiscQty2;'  + convert(varchar, @selfDiscardQty2) + ';'
  ----  + 'DiscQty3;'  + convert(varchar, @selfDiscardQty3) + ';'
  ----  + 'DiscQty4;'  + convert(varchar, @selfDiscardQty4) + ';'
  ----  + 'LeftQty1;'  + convert(varchar, @selfLeftQty1) + ';'
  ----  + 'LeftQty2;'  + convert(varchar, @selfLeftQty2) + ';'
  ----  + 'LeftQty3;'  + convert(varchar, @selfLeftQty3) + ';'
  ----  + 'LeftQty4;'  + convert(varchar, @selfLeftQty4) + ';'
  --  );
    --++++++++++++++++++++++++++++++++++++++++++++++++++++

    SET @PrsPlanQty = @MesPlanQty
    --此处原意是把当下的工位的计划数量调整一下, 其根据其父订单的计划数量减去当时其在此工位之前的下线数量.
    --如下的代码就是当时的计算逻辑, 因为其比较繁琐并且不可靠, 因此这里没有坚持继续使用此原则.
    --此段代码的意义是当下订单为补单的情况下, 需要计算当下工序的计划数量.
    --为了看清现有流程, 此处的不需要的代码已经删除, 如有查看需要, 可以从SVN的较低版本查看早于本版本日期的即有之: 2017-09-04.

    BEGIN TRANSACTION

     --2.如果当下工单的状态为"待生产", "产前调整中", 则需要设置工单为"生产进行中",

     -- 需求文档描述原文文本: 一个订单的首个工序的操作计数等于1时(各PLC参数派发完成后，会调整操作计数为0)，则调整该订单状态为“生产进行中”
     -- 个人觉得: 产量为1的限制条件可以去掉, 这样可以防止生产线的某些漏操作, 造成系统一直没有更改工单状态的严重事故, 如果条件去除, 则可以给工单状态重大的延后的弥补机会.
     -- 当下已经不使用这个作为订单的状态更改触发机制了, 其使用了MES Code的产生作为触发条件并进行工单状态修改.[2017-09-12]
     -- IF ( @WorkOrderStatus = 0 OR @WorkOrderStatus = 1 ) AND @StartFlag = 1 --AND @TagFinishQty = 1
     -- BEGIN
     --     UPDATE MFG_WO_List 
     --     SET
     --         MesStatus = 2 
     --        ,MesActualStartTime = GETDATE()
     --     WHERE
     --         ErpWorkOrderNumber  = @WorkOrderNumber
     --     AND MesWorkOrderVersion = @WorkOrderVersion
     --     AND ( MesStatus = 0 OR MesStatus = 1 );
     -- END

     --3. 更新当下工序的实际产出数量, 
     -- 这里的操作 "不要" 和下面的 "本工序产出完成" 的另一个条件分支合并起来, 
     -- 因为, 可能会有订单数量为 "1" 情况, 这样就可能一次产量输出事件就完成了工单而导致工单号码和版本号密码没有机会更新
     -- 这样写的方法会多执行一次数据表的更新操作, 工序表很小, 因此效率问题不大.

     -- 此处只需要记录计数器的计数数值即可, 其工序的工单值不再考虑, 工序的工单信息仅仅需要参数派发机制来完成.
     UPDATE Mes_Process_List
     SET    
          FinishQty        = @TagFinishQty
         ,ParamTime        = GETDATE() 
         ,ParamName        = @TagName   
         ,ParamValue       = @TagValue 
     WHERE 
          ProcessCode = @ProcessCode
     
     --本工序产出完成
     --工序订单状态的变更, 已经不在此处来完成了, 其是使用CS(产品变更)完成信号的触发来进行和下一个订单翻转完成的机制[2017-09-21]
     --IF @PrsPlanQty <= @FinishQty 
     --BEGIN
     --    UPDATE Mes_Process_List
     --    SET    
     --        FinishQty   = -1
     --    WHERE 
     --        ProcessCode = @pProcessCode
     --END

    -------------------为了验收的需要, 暂时屏蔽复杂的操作.
    --RETURN;
    --------+++++++++++

     --更新订单产量
     IF @FinalFlag = 1 AND @WorkOrderStatus = 2 
     BEGIN
         UPDATE MFG_WO_List
         SET MesFinishQty = @TagFinishQty
         WHERE
             ErpWorkOrderNumber  = @WorkOrderNumber
         AND MesWorkOrderVersion = @WorkOrderVersion
         AND MesStatus           = 2;
     END
        
     --结束工单, FinalFlag = 1 (当下只有"码垛"这个工位)表示当下工序是生产线的最后一个计数点, 其可以作为判断工单是否完成的一个节点.
     IF @FinalFlag = 1 AND @PrsPlanQty <= @FinishQty AND @WorkOrderStatus = 2 
     BEGIN
         --结束工单主记录
         UPDATE MFG_WO_List
         SET 
              MesStatus = 3
             ,MesActualFinishTime = GETDATE()
         WHERE
             ErpWorkOrderNumber  = @WorkOrderNumber
         AND MesWorkOrderVersion = @WorkOrderVersion
         AND MesStatus           = 2 ;

         --把所有涉及此订单的工序表记录全部重置(因为, 有的工序只有物料拉动, 但却不进行产出计数的情况.)
         UPDATE Mes_Process_List
         SET    
              FinishQty  = -1
             ,ParamTime  = GETDATE() 
             ,ParamName  = @TagName   
             ,ParamValue = @TagValue                      
         WHERE 
             WorkOrderNumber  = @WorkOrderNumber
         AND WorkOrderVersion = @WorkOrderVersion;  --这里需要把所有和这个工单有关系的标致都要结单.
     END
      
     COMMIT TRANSACTION
    --(需要判断当前是否为全局"暂停/正常"标志, 此处涉及到异常恢复情况场景, 比较复杂, 时间关系不考虑)
GO

-- 客户程序 触发了 RFID 读数据动作
ALTER PROCEDURE  [dbo].[usp_Mfg_Client_Trig_RFID]
      @LabelUID         AS VARCHAR  (50) = ''      --标签的物理地址(MAC)
     ,@LabelValue       AS VARCHAR  (50) = ''      --标签的序号值(标签新购入时写入的一个序列号值)
     ,@AeraCode         AS VARCHAR  (50) = ''      --标签读取头的位置号,形如: RFID01...RFID09
     ,@MesCode          AS VARCHAR  (50) = ''      --MES编号
     ,@ReadTime         AS DATETIME      = ''      --Client读取时间
AS
    --此模块目前和本系统尚没有关联, 因此直接返回即可.
    RETURN;    
GO
