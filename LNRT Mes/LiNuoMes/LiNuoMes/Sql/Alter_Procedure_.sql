
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
        [RFCName] = @RFCName
    AND
    ( 
        ( @StdCode = StdCode)
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
             WHEN  3 THEN '发料完成'    
             WHEN  2 THEN '发料失败!!!'
             WHEN  1 THEN '发料进行中...'
             WHEN  0 THEN '等待发料...'
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
        ,MesDiscardQty1 + MesDiscardQty1  DiscardQty
        ,MesLeftQty1   LeftQty1
        ,MesLeftQty2   LeftQty2
    FROM 
        MFG_WO_List AS WO 
    WHERE            
            (DATEDIFF(DAY, WO.MesPlanStartTime, CONVERT(DATE, @PlanDate)) = 0 OR WO.MesStatus = 3 ) 
        AND (WO.ErpWorkOrderNumber = @WorkOrderNumber OR @WorkOrderNumber='')
        AND MesDiscardQty1 + MesDiscardQty1 + MesLeftQty1 + MesLeftQty2 > 0
        
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
            WHEN AbnormalPoint = '1' AND AbnormalType = 3 THEN 1 
            ELSE 0
            END 
        ) AS LeftQty1
        ,SUM(
            CASE 
            WHEN AbnormalPoint = '2' AND AbnormalType = 3  OR AbnormalPoint = '3' THEN 1 --第三个下线点仅存在"未完工"下线, 但是其对应的上线点与第二个下线点的上线工序点相同
            ELSE 0
            END 
        ) AS LeftQty2
        ,SUM(
            CASE   
            WHEN AbnormalPoint = '1' AND AbnormalType = 2 THEN 1 
            ELSE 0 
            END 
        ) AS DiscardQty1
        ,SUM(
            CASE   
            WHEN AbnormalPoint = '2' AND AbnormalType = 2 THEN 1 
            ELSE 0 
            END 
        ) AS DiscardQty2
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
    DECLARE @APO1        VARCHAR(50);
    DECLARE @APO2        VARCHAR(50);
    DECLARE @APO3        VARCHAR(50);
    DECLARE @ATY2        INT;
    DECLARE @ATY3        INT;
    DECLARE @PlanQty     INT;


    --选择上线工序
    SELECT
         @APO1    = SUM(CASE AbnormalPoint WHEN '1' THEN 1 ELSE 0 END ),
         @APO2    = SUM(CASE AbnormalPoint WHEN '2' THEN 1 ELSE 0 END ),
         @APO3    = SUM(CASE AbnormalPoint WHEN '3' THEN 1 ELSE 0 END ),        
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
                   ([MesStartPoint], [MesInturnNumber] ,[MesWorkOrderType], [MesWorkOrderVersion], [MesPlanQty] , [MesCreateUser], [MesPlanStartTime] ,[MesPlanFinishTime] ,[MesCostTime] ,              [ErpWorkOrderNumber] ,[ErpGoodsCode] ,[ErpGoodsDsca] ,[ErpPlanQty] ,[ErpPlanCreateTime] ,[ErpPlanStartTime] ,[ErpPlanFinishTime] ,[ErpPlanReleaseTime] ,[ErpWorkGroup] ,[ErpOrderType] ,[ErpOrderStatus] ,[ErpOBJNR] ,[ErpZTYPE], [MesUnitCostTime], [MesCustomerID], [MesOrderComment])
    SELECT          @StartPoint,     -1 ,                1 ,                 @WorkOrderVersion ,   @PlanQty ,     @UserName,        GETDATE() ,         GETDATE() ,         MesUnitCostTime * @PlanQty , [ErpWorkOrderNumber] ,[ErpGoodsCode] ,[ErpGoodsDsca] ,[ErpPlanQty] ,[ErpPlanCreateTime] ,[ErpPlanStartTime] ,[ErpPlanFinishTime] ,[ErpPlanReleaseTime] ,[ErpWorkGroup] ,[ErpOrderType] ,[ErpOrderStatus] ,[ErpOBJNR] ,[ErpZTYPE], [MesUnitCostTime], [MesCustomerID], [MesOrderComment]
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
        ,WO.MesPlanQty PlanQty
        ,FORMAT(WO.MesPlanStartTime, 'yyyy-MM-dd hh:mm')  PlanStartTime
        ,FORMAT(WO.MesPlanFinishTime,'yyyy-MM-dd hh:mm')  PlanFinishTime
        ,WO.MesCostTime      CostTime
        ,WO.MesUnitCostTime  UnitCostTime
        ,WO.MesWorkOrderType WorkOrderType
        ,WO.MesCustomerID    CustomerID
        ,WO.MesOrderComment  OrderComment
        ,MesDiscardQty1 + MesDiscardQty2  DiscardQty
        ,MesLeftQty1         LeftQty1
        ,MesLeftQty2         LeftQty2
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
        DiscardQty1      INT,
        DiscardQty2      INT
    )
    INSERT INTO @ABN
    EXEC usp_Mfg_Wip_Data_Abnormal_SummayQty @WorkOrderNumber, @WorkOrderVersion

    UPDATE Mfg_WO_List 
    SET 
         Mfg_WO_List.MesLeftQty1   = ABN.LeftQty1
        ,Mfg_WO_List.MesLeftQty2   = ABN.LeftQty2
        ,Mfg_WO_List.MesDiscardQty1= ABN.DiscardQty1
        ,Mfg_WO_List.MesDiscardQty2= ABN.DiscardQty2
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

-- 取得最后近次的正常生产的RFID所代表工单等信息
-- 此存储过程在上线调试时[需要重写]
ALTER PROCEDURE  [dbo].[usp_Mfg_Wip_Data_Rfid_getLast]
      @RFID               AS NVARCHAR (50)
     ,@WorkOrderNumber    AS VARCHAR  (50) OUTPUT
     ,@WorkOrderVersion   AS INT           OUTPUT
     ,@GoodsCode          AS VARCHAR  (50) OUTPUT
     ,@ProcessCode        AS VARCHAR  (50) OUTPUT
     ,@AbnormalPoint      AS VARCHAR  (50) OUTPUT
AS
    DECLARE @MAXID INT;

    SELECT
        @MAXID = MAX(ID),
        @AbnormalPoint =
                CASE
                    WHEN COUNT(1) <= 3                    THEN 3
                    WHEN COUNT(1)  > 3 AND COUNT(1) <= 5  THEN 3
                    WHEN COUNT(1)  > 5                    THEN 3
                    ELSE                                       3
                END
    FROM MFG_WIP_Data_RFID
    WHERE
           RFID   = @RFID
       AND Status = 0; --此处定义的是正常生产时产生的最后的记录工序点.
       
    SELECT
         @GoodsCode        = WO.ErpGoodsCode
        ,@WorkOrderNumber  = WO.ErpWorkOrderNumber 
        ,@WorkOrderVersion = WO.MesWorkOrderVersion 
        ,@ProcessCode      = RF.ProcessCode
    FROM
          MFG_WIP_Data_RFID RF
         ,MFG_WO_List WO
    WHERE
          RF.WorkOrderNumber  = WO.ErpWorkOrderNumber
      AND RF.WorkOrderVersion = WO.MesWorkOrderVersion
      AND RF.ID               = @MAXID
GO

--取得下线记录详细信息
ALTER PROCEDURE  [dbo].[usp_Mfg_Wip_Data_Abnormal_Detail]
      @AbId               AS VARCHAR  (50)
     ,@RFID               AS NVARCHAR (50)
     ,@UserName           AS NVARCHAR (50)
AS
    IF @AbId <> '0'
    BEGIN
        SELECT
             AB.ID                 ID
            ,AB.RFID               RFID
            ,AB.AbnormalPoint      AbnormalPoint
            ,AB.AbnormalProduct    AbnormalProduct
            ,AB.AbnormalType       AbnormalType
            ,AB.AbnormalTime       AbnormalTime
            ,AB.AbnormalUser       AbnormalUser
            ,WO.ErpGoodsCode       GoodsCode
            ,WO.ErpWorkOrderNumber WorkOrderNumber
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
        DECLARE @AbnormalPoint    VARCHAR(50);
    
        EXEC usp_Mfg_Wip_Data_Rfid_getLast @RFID, @WorkOrderNumber OUTPUT, @WorkOrderVersion OUTPUT, @GoodsCode OUTPUT, @ProcessCode OUTPUT, @AbnormalPoint OUTPUT
    
        SELECT
             0                 ID
            ,@RFID             RFID
            ,@AbnormalPoint    AbnormalPoint
            ,0                 AbnormalProduct
            ,1                 AbnormalType
            ,GETDATE()         AbnormalTime
            ,@UserName         AbnormalUser
            ,''                AbnormalReason
            ,@GoodsCode        GoodsCode
            ,@WorkOrderNumber  WorkOrderNumber
    END
GO

--新建下线记录信息
ALTER PROCEDURE  [dbo].[usp_Mfg_Wip_Data_Abnormal_Add]
     @AbId               AS INT
    ,@RFID               AS NVARCHAR (50)
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
    DECLARE @AbnormalPointSP  VARCHAR(50);  --这个值现在已经不需要了, 已经可以从存储过程的参数中获取了: 即用户自己手工决定下线点.
    
    EXEC usp_Mfg_Wip_Data_Rfid_getLast @RFID, @WorkOrderNumber OUTPUT, @WorkOrderVersion OUTPUT, @GoodsCode OUTPUT, @ProcessCode OUTPUT, @AbnormalPointSP OUTPUT
    
    --检查传入的RFID是否有效
    IF LEN(@WorkOrderNumber) = 0 
    BEGIN
        SET @CatchError = 1;
        SET @RtnMsg = '系统未发现在此号码的生产数据, 请您仔细核对!';
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
        SET @RtnMsg = '系统发现在此下线点已经存在此号码的下线, 并且其当下尚未完成补修!';
        RETURN;
    END

    --此处应该加入检查订单是否已经产生了补单状态. 
    --考虑到实际情况觉得没有必要加入此种判断. 也许需要去除此种判断[需要重写]
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
           ( RFID , AbnormalPoint , AbnormalType , AbnormalTime , AbnormalUser , AbnormalProduct , WorkOrderNumber , WorkOrderVersion , UpdateUser )
    VALUES (@RFID ,@AbnormalPoint ,@AbnormalType ,@AbnormalTime ,@AbnormalUser ,@AbnormalProduct ,@WorkOrderNumber ,@WorkOrderVersion ,@UpdateUser);

    --更新订单的报废, 未完工数量
    EXEC [usp_Mfg_Wo_List_ABN_Qty_Update] @WorkOrderNumber, @WorkOrderVersion;

    --此处相同号码多次补修, 重复计算额外领料数量, 
    --日后根据生产使用实践, 可以根据实际情况把此条件去掉或保留.
    --[需要重写]
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
    ,@RFID               AS NVARCHAR (50)
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
         AbnormalType   = @AbnormalType
        ,AbnormalTime   = @AbnormalTime
        ,AbnormalUser   = @AbnormalUser
        ,AbnormalPoint  = @AbnormalPoint
        ,AbnormalProduct= @AbnormalProduct
        ,UpdateUser     = @Updateuser
        ,UpdateTime     = GETDATE()
    WHERE
         ID = @AbId
    
    IF @@ROWCOUNT > 0  --说明最后语句更新了至少一条记录.
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
ALTER PROCEDURE  [dbo].[usp_Mfg_Wip_Data_Abnormal_Mtl_Insert]
     @AbId               AS VARCHAR  (50)
AS
    --需要确定从原用料表中确定从何处工序代码开始计算额外申领物料
    DECLARE @FinalProcessCode   VARCHAR(50);
    DECLARE @FinalInturnNumber  INT;
    DECLARE @AbnormalPoint      VARCHAR(50);
    DECLARE @AbnormalType       INT;

    SELECT 
         @AbnormalPoint = AbnormalPoint
        ,@AbnormalType  = AbnormalType
    FROM 
        MFG_WIP_Data_Abnormal 
    WHERE 
        ID = @AbId;

    SELECT 
        @FinalProcessCode = 
        CASE --此处在现场调试的时候 [需要重写]
            WHEN @AbnormalPoint = '1' THEN '0010'
            WHEN @AbnormalPoint = '2' THEN '0030'
            WHEN @AbnormalPoint = '3' THEN '0040'
            ELSE                           'XXXX'
        END;

    --得到下线工位的工序代码的顺序号
    SELECT 
        @FinalInturnNumber = InturnNumber 
    FROM 
        Mes_Process_List 
    WHERE 
        ProcessCode = @FinalProcessCode

    --只有 "报废", "未完工" 的下线才需要进行额外物料申领操作.
    IF @AbnormalType <> 1
    BEGIN
        INSERT INTO MFG_WIP_Data_Abnormal_MTL 
              ( AbnormalID,   ProcessCode,     ItemNumber,     ItemDsca,     UOM,    UpdateUser, LeftQty, RequireQty)
        SELECT @AbId,     MTL.ProcessCode, MTL.ItemNumber, MTL.ItemDsca, MTL.UOM, AB.UpdateUser, 
        CASE 
            WHEN PS.InturnNumber <= @FinalInturnNumber THEN 0
            ELSE MTL.Qty/WO.MesPlanQty
        END AS LeftQty, 
        CASE 
            WHEN PS.InturnNumber  > @FinalInturnNumber THEN 0
            ELSE MTL.Qty/WO.MesPlanQty
        END AS RequireQty 
        FROM 
            MFG_WO_MTL_List       MTL,
            MFG_WO_List           WO,
            Mes_Process_List      PS,
            MFG_WIP_Data_Abnormal AB
        WHERE 
        --此处逻辑为: 应该根据"根订单"(WorkOrderVersion = 0)计算产品用料. 
        --因为如果根据子订单的话，其用料数据(额外领料单)可能是用户调整过的.
            WO.ErpWorkOrderNumber   = MTL.WorkOrderNumber
        AND WO.MesWorkOrderVersion  = MTL.WorkOrderVersion
        AND PS.ProcessCode          = MTL.ProcessCode 
        AND WO.ErpWorkOrderNumber   = AB.WorkOrderNumber
        AND WO.MesWorkOrderVersion  = 0 --逻辑上此处右侧值需要为 0 则可以使用根订单的物料使用数据了.
        AND AB.ID                   = @AbId
        AND UPPER(MTL.Backflush) <> 'X' 
        AND UPPER(MTL.[BULK]   ) <> 'X' 
        AND UPPER(MTL.Phantom  ) <> 'X' --需要三者同时都不许为X的状态才是我们需要考虑的计件物料. 2017-06-13 17:16
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
ALTER PROCEDURE  [dbo].[usp_Mfg_Wo_List_Adjust_inturn]
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
               (WOID, AUFNR,              MATNR,        MAKTX,        GAMNG,      FinishQty,             MesCreateUser, MesCreateTime, MesModifyTime, ErpCfmStatus, MesCfmStatus)
        SELECT  ID,   ErpWorkOrderNumber, ErpGoodsCode, ErpGoodsDsca, ErpPlanQty, CONVERT(INT, @ROCQTY), @UserName,     GETDATE(),     GETDATE(),     0,            0 
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
               (WOID, AUFNR,              MATNR,        MAKTX,        GAMNG,      FinishQty,    MesCreateUser, MesCreateTime, MesModifyTime, ErpMvtStatus, MesMvtStatus)
        SELECT  ID,   ErpWorkOrderNumber, ErpGoodsCode, ErpGoodsDsca, ErpPlanQty, MesFinishQty, 'MES_SYS',     GETDATE(),     GETDATE(),     0,            0 
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
            MTL.ID, ItemNumber, ItemDsca
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
    AND WO.ID=@WOID
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
     @PLCID            AS INT                  --PLCID
AS
     SELECT *
     FROM Mes_PLC_Parameters
     WHERE PLCID = @PLCID
     AND OperateType IN ( 'W', 'RW') AND ApplModel = 'VS'
     ORDER BY ParamName
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
     SELECT *
     FROM Mes_PLC_Parameters
     WHERE PLCID = @PLCID
      AND ApplModel = 'MT'
     ORDER BY ParamName
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

    EXEC usp_Mes_GetNewSerialNo_Output 'MES2PLC','M2P', 10, @BatchNo OUTPUT;

    --开始真正的插入到接口表的操作.
    --参数派发
    INSERT INTO Mes_PLC_TransInterface ( BATCHNUM, PLCID, SOURCEID, ParamName, ParamType, ParamValue, OperateCommand, OperateUser,  Status)
                                  SELECT @BatchNo, PLCID, ID,       ParamName, ParamType, CASE WHEN ApplModel = 'VS' THEN ParamValue ELSE '1' END , OperateCommand, @OperateUser, 0
                                  FROM Mes_PLC_Parameters
                                  WHERE PLCID IN ( SELECT PLCID FROM @ListTB)
                                  AND OperateType IN ( 'W', 'RW') AND ApplModel = @SenderType;

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
    
        DECLARE @WorkOrderStatus    AS INT;
        DECLARE @GoodsCode          AS VARCHAR (50);
        DECLARE @pProcessCode       AS NVARCHAR(50); --plc   processcode
        DECLARE @mProcessCode       AS NVARCHAR(50); --param processcode


        UPDATE Mes_Process_List
        SET 
             WorkOrderNumber  = @WorkOrderNumber
            ,WorkOrderVersion = @WorkOrderVersion
            ,FinishQty        = 0
            ,PlanQty          = @PrsPlanQty     
        FROM 
            Mes_PLC_List         
        WHERE 
            Mes_PLC_List.ProcessCode = Mes_Process_List.ProcessCode 
        AND Mes_PLC_List.ID IN (SELECT PLCID FROM @ListTB) 

        UPDATE MFG_WO_List
        SET 
            MesStatus = 1
        FROM 
            Mes_PLC_List         
        WHERE 
            MesStatus = 0
        AND ErpWorkOrderNumber  = @WorkOrderNumber
        AND MesWorkOrderVersion = @WorkOrderVersion

        --计划产量,这里实现的很不好, 需要考虑工单数量,未完工数量,报废数量 [需要重写]
        INSERT INTO Mes_PLC_TransInterface ( BATCHNUM, PLCID, SOURCEID, ParamName, ParamType, ParamValue, OperateCommand, OperateUser,  Status)
                                      SELECT @BatchNo, PLCID, ID,       ParamName, ParamType, @PrsPlanQty,OperateCommand, @OperateUser, 0
                                      FROM Mes_PLC_Parameters
                                      WHERE PLCID IN ( SELECT PLCID FROM @ListTB)
                                      AND OperateType IN ( 'W', 'RW') AND ApplModel = 'QS';
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

--用以获得MES序列号值
--当前的编码规则为: 年月日 + 四位序列号
ALTER PROCEDURE [dbo].[usp_Mes_getMesCode]
AS
    DECLARE @MesCode        VARCHAR(50)
    DECLARE @SerialName     VARCHAR(50)
    DECLARE @SerialNumber   VARCHAR(15) 

    SET @SerialName    = FORMAT(GETDATE(), 'yyMMdd');
    EXEC usp_Mes_GetNewSerialNo_Output @SerialName, 'RFID', 8, @SerialNumber OUTPUT
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
ALTER PROCEDURE [dbo].[usp_Mes_GetNewSerialNo_Output]
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
     [AUFNR] ,[MATNR] ,[MAKTX] ,[GAMNG] ,[ERDAT] ,[GSTRP] ,[GLTRP] ,[FTRMI] ,[WERKS] ,[AUART] ,[TXT30] ,[OBJNR] ,[ZTYPE] ,[GAMNG] ,[GSTRP] ,[GLTRP] ,[GAMNG] * 2 ,2
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
     MTL.RSNUM ,MTL.RSPOS ,MTL.AUFNR ,MTL.POSNR ,MTL.MATNR ,MTL.MAKTX ,MTL.ERFMG ,MTL.ERFME ,MTL.VORNR ,MTL.ARBPL ,MTL.KTEXT ,MTL.LGORT ,MTL.DUMPS ,MTL.SCHGT ,MTL.RGEKZ ,MTL.WERKS, 'MES_SYS', ''
    FROM
        ERP_WO_MTL_List MTL,
        #TMP_WO WO
    WHERE
           MTL.AUFNR = WO.ErpWorkOrderNumber
       AND WO.ID IN (SELECT TMP_ID FROM #TMP_FULL WHERE TMP_ID IS NOT NULL AND MES_ID IS NULL)
       --此条件, 最好不要去掉, 这样可以保证SAP多次更新的时候不至于串皮, 此处取了一个中间折扣: 相差不超过1分钟的可以接受[需要重写]
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

ALTER PROCEDURE  [dbo].[usp_Mfg_Wo_Mtl_Pull_Update_OTFlag]
AS
    UPDATE MFG_WO_MTL_Pull 
    SET MFG_WO_MTL_Pull.OTFlag = 
    CASE 
       WHEN DATEDIFF(MINUTE, MTL.PullTime , GETDATE()) - ISNULL(HH.MinTrigQty,30) > 0 THEN 1
       ELSE 0
    END
    FROM 
    MFG_WO_MTL_Pull MTL
    LEFT JOIN Mes_Threshold_List HH on mtl.ItemNumber = HH.ItemNumber 
    WHERE MTL.Status = 0
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
        @ApplModel = Mes_PLC_Parameters.ApplModel 
    FROM 
        Mes_PLC_Parameters, Mes_PLC_List 
    WHERE 
        Mes_PLC_Parameters.PLCID = Mes_PLC_List.ID
    AND Mes_PLC_Parameters.ParamName = @TagName 
    AND Mes_PLC_List.GoodsCode = '0000000000';
    
    INSERT Log_Mfg_Plc_Tag_Trig (TagName, TagValue, ProcessCode, Category) VALUES(@TagName, @TagValue, @ProcessCode, ISNULL(@ApplModel,''));

    IF @ApplModel = 'ET' 
    BEGIN
        EXEC [usp_Mfg_Plc_Trig_ET] @TagName, @TagValue, @ProcessCode; RETURN;
    END

    IF @ApplModel = 'MT' 
    BEGIN
        EXEC [usp_Mfg_Plc_Trig_MT] @TagName, @TagValue, @ProcessCode; RETURN;
    END

    IF @ApplModel = 'QT' 
    BEGIN
        EXEC [usp_Mfg_Plc_Trig_QT] @TagName, @TagValue, @ProcessCode; RETURN;
    END
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

-- PLC 触发了 物料拉动 动作
ALTER PROCEDURE  [dbo].[usp_Mfg_Plc_Trig_MT]
      @TagName            AS VARCHAR  (50)       
     ,@TagValue           AS VARCHAR  (50) = ''  
     ,@ProcessCode        AS VARCHAR  (50) = ''  
AS
    DECLARE @ProcessFinishQty   AS INT;
    DECLARE @WorkOrderNumber    AS VARCHAR (50);
    DECLARE @WorkOrderVersion   AS INT;
    DECLARE @WorkOrderStatus    AS INT;
    DECLARE @GoodsCode          AS VARCHAR (50);
    DECLARE @pProcessCode       AS NVARCHAR(50); --plc   processcode
    DECLARE @mProcessCode       AS NVARCHAR(50); --param processcode
    DECLARE @MesPlanQty         AS INT;

    --共需要3步操作: 
    --1.查找工序清单, 找到当下的工单, 

    --查找工序
    SELECT 
        @pProcessCode = Mes_PLC_List.ProcessCode, 
        @mProcessCode = Mes_PLC_Parameters.ProcessCode
    FROM 
        Mes_PLC_Parameters, Mes_PLC_List 
    WHERE 
        Mes_PLC_Parameters.PLCID = Mes_PLC_List.ID
    AND Mes_PLC_Parameters.ParamName = @TagName 
    AND Mes_PLC_List.GoodsCode = '0000000000';

    --查找工单
    SELECT 
         @WorkOrderNumber  = WorkOrderNumber
        ,@WorkOrderVersion = WorkOrderVersion
        ,@ProcessFinishQty = FinishQty
    FROM Mes_Process_List 
    WHERE ProcessCode = @mProcessCode;

    --如果订单已经完结, 则找到当下排程的下一个工单
    IF ISNULL(@ProcessFinishQty, -1) = -1
    BEGIN
        --如果工单为空, 则需要进行一下初始化
        IF ISNULL(@WorkOrderNumber, '') = ''
        BEGIN
            SELECT @WorkOrderNumber = '', @WorkOrderVersion = -1;
        END
        EXEC [usp_Mfg_Wo_List_get_Next_Available] @WorkOrderNumber OUTPUT, @WorkOrderVersion OUTPUT; 
    END

    IF ISNULL(@WorkOrderNumber, '') = ''
    BEGIN
        --说明当下没有排程计划. 此时直接返回
        RETURN;
    END 

    --2.如果当下工单的状态为"待生产", 则需要设置工单为"产前调整中",
    --取出工单的状态
    SELECT @WorkOrderStatus = MesStatus
         , @GoodsCode       = ErpGoodsCode
         , @MesPlanQty      = MesPlanQty
    FROM MFG_WO_List
    WHERE
         ErpWorkOrderNumber  = @WorkOrderNumber
     AND MesWorkOrderVersion = @WorkOrderVersion

     --判断, 更改状态
     IF @WorkOrderStatus = 0 
     BEGIN
         UPDATE MFG_WO_List 
         SET MesStatus = 1 
         WHERE
             ErpWorkOrderNumber  = @WorkOrderNumber
         AND MesWorkOrderVersion = @WorkOrderVersion;
     END

     --设定工序表的当下工单
     UPDATE Mes_Process_List
     SET    
          WorkOrderNumber  = @WorkOrderNumber
         ,WorkOrderVersion = @WorkOrderVersion
         ,FinishQty        = 0
         ,PlanQty          = @MesPlanQty
         ,ParamTime        = GETDATE() 
         ,ParamName        = @TagName   
         ,ParamValue       = @TagValue 
     WHERE 
         ProcessCode = @mProcessCode
     AND FinishQty   = -1;

     --3. 产生拉料动作.
     INSERT INTO MFG_WO_MTL_Pull 
           ( WorkOrderNumber,      WorkOrderVersion,     ItemNumber,  ItemDsca,                  ProcessCode,  UOM,                   Qty,                        PullUser )
     SELECT
          ABC.WorkOrderNumber, ABC.WorkOrderVersion, ABC.ItemNumber, ISNULL(THR.ItemName,''), ABC.ProcessCode, ISNULL(THR.UOM, 'EA'), ISNULL(THR.MaxPullQty, 30), 'MES'         
     FROM 
     (
     SELECT
        @WorkOrderNumber              WorkOrderNumber
      , @WorkOrderVersion             WorkOrderVersion
      , Mes_PLC_Parameters.ItemNumber ItemNumber
      , @mProcessCode                 ProcessCode        
     FROM 
         Mes_PLC_Parameters
       , Mes_PLC_List 
     WHERE 
         Mes_PLC_Parameters.PLCID = Mes_PLC_List.ID
     AND Mes_PLC_Parameters.ParamName = @TagName 
     AND Mes_PLC_List.GoodsCode = @GoodsCode
     ) AS ABC
     LEFT JOIN Mes_Threshold_List AS THR ON ABC.ItemNumber = THR.ItemNumber
  --   LEFT JOIN MFG_WO_MTL_List    AS MTL ON ABC.ItemNumber = MTL.ItemNumber 
  --                                      AND MTL.WorkOrderNumber = MTL.WorkOrderNumber 
  --                                      AND MTL.WorkOrderVersion = 0 --要从用料全集中获取(根订单中包含全部用料信息, 子单中把那些非计件用料屏蔽了.)

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
    DECLARE @pProcessCode       AS NVARCHAR(50); --plc   processcode
    DECLARE @mProcessCode       AS NVARCHAR(50); --param processcode
    DECLARE @TagFinishQty       AS INT;

    SET @TagFinishQty = CONVERT(INT, @TagValue);

    --共需要3步操作: 
    --1.查找工序清单, 找到当下的工单, 

    --查找工序
    SELECT 
        @pProcessCode = Mes_PLC_List.ProcessCode, 
        @mProcessCode = Mes_PLC_Parameters.ProcessCode
    FROM 
        Mes_PLC_Parameters, Mes_PLC_List 
    WHERE 
        Mes_PLC_Parameters.PLCID = Mes_PLC_List.ID
    AND Mes_PLC_Parameters.ParamName = @TagName 
    AND Mes_PLC_List.GoodsCode = '0000000000';

    --查找工单
    SELECT 
         @WorkOrderNumber  = WorkOrderNumber
        ,@WorkOrderVersion = WorkOrderVersion
        ,@ProcessFinishQty = FinishQty
    FROM Mes_Process_List 
    WHERE ProcessCode = @pProcessCode; --此处和物料拉动不同, 产量计数是基于PLC为单位的.

    --如果订单已经完结, 则找到当下排程的下一个工单
    IF ISNULL(@ProcessFinishQty, -1) = -1
    BEGIN
        --如果工单为空, 则需要进行一下初始化
        IF ISNULL(@WorkOrderNumber, '') = ''
        BEGIN
            SELECT @WorkOrderNumber = '', @WorkOrderVersion = -1;
        END
        EXEC [usp_Mfg_Wo_List_get_Next_Available] @WorkOrderNumber OUTPUT, @WorkOrderVersion OUTPUT; 
    END

    IF ISNULL(@WorkOrderNumber, '') = ''
    BEGIN
        --说明当下没有排程计划. 此时直接返回
        RETURN;
    END 

    DECLARE @MesPlanQty       INT; --原始订单计划数量
    DECLARE @PrsPlanQty       INT; --Process计划数量
    DECLARE @selfDiscardQty1  INT; --本订单的待修或报废数量
    DECLARE @selfDiscardQty2  INT; --本订单的待修或报废数量
    DECLARE @selfLeftQty1     INT; --本订单的待修或报废数量
    DECLARE @selfLeftQty2     INT; --本订单的待修或报废数量

    DECLARE @baseDiscardQty1  INT; --母订单的待修或报废数量
    DECLARE @baseDiscardQty2  INT; --母订单的待修或报废数量
    DECLARE @baseLeftQty1     INT; --母订单的待修或报废数量
    DECLARE @baseLeftQty2     INT; --母订单的待修或报废数量

    DECLARE @AbnormalRegion   INT;
    DECLARE @FinalFlag        INT;
    DECLARE @FinishQty        INT;


    --取得本工序的基本配置信息
    SELECT 
         @AbnormalRegion = AbnormalRegion
        ,@FinalFlag      = FinalFlag 
    FROM Mes_Process_List
    WHERE 
        ProcessCode = @pProcessCode
    
    --取得本订单的信息,状态
    SELECT
         @MesPlanQty      = MesPlanQty        
        ,@selfDiscardQty1 = MesDiscardQty1
        ,@selfDiscardQty2 = MesDiscardQty2
        ,@selfLeftQty1    = MesLeftQty1
        ,@selfLeftQty2    = MesLeftQty2
        ,@WorkOrderStatus = MesStatus
        ,@GoodsCode       = ErpGoodsCode   
    FROM
         MFG_WO_List
    WHERE
        ErpWorkOrderNumber  = @WorkOrderNumber
    AND MesWorkOrderVersion = @WorkOrderVersion;

    IF @AbnormalRegion = 1 
    BEGIN
       SET @FinishQty = @TagFinishQty; 
    END
 
    IF @AbnormalRegion = 2
    BEGIN
       SET @FinishQty = @TagFinishQty + @selfDiscardQty1 + @selfLeftQty1;
    END
    
    IF @AbnormalRegion = 3
    BEGIN
       SET @FinishQty = @TagFinishQty + @selfDiscardQty1 + @selfDiscardQty2 + @selfLeftQty1 + @selfLeftQty2;
    END

    SET @PrsPlanQty = @MesPlanQty

    --此段代码的意义是当下订单为补单的情况下, 需要计算当下工序的计划数量.
    -- IF @WorkOrderVersion = 0 
    -- BEGIN  --正常订单的情况
    --     SET @PrsPlanQty = @MesPlanQty
    -- END 
    -- ELSE  
    -- BEGIN  --下线补单的情况
    --     SELECT
    --          @baseDiscardQty1 = MesDiscardQty1
    --         ,@baseDiscardQty2 = MesDiscardQty2
    --         ,@baseLeftQty1    = MesLeftQty1
    --         ,@baseLeftQty2    = MesLeftQty2
    --     FROM
    --          MFG_WO_List
    --     WHERE
    --          ErpWorkOrderNumber  = @WorkOrderNumber
    --      AND MesWorkOrderVersion = @WorkOrderVersion - 1;
    -- 
    --     IF @AbnormalRegion = 1
    --     BEGIN
    --         SET @PrsPlanQty = @baseDiscardQty1 + @baseDiscardQty2;
    --     END
    -- 
    --     IF @AbnormalRegion = 2
    --     BEGIN
    --         SET @PrsPlanQty = @baseDiscardQty1 + @baseDiscardQty2 + @baseLeftQty1;
    --     END  
    -- 
    --     IF @AbnormalRegion = 3
    --     BEGIN
    --         SET @PrsPlanQty = @baseDiscardQty1 + @baseDiscardQty2 + @baseLeftQty1 + @baseLeftQty2;
    --     END       
    -- END
   
    BEGIN TRANSACTION

     --2.如果当下工单的状态为"待生产", "产前调整中", 则需要设置工单为"生产进行中",
     IF @WorkOrderStatus = 0 OR @WorkOrderStatus = 1
     BEGIN
         UPDATE MFG_WO_List 
         SET
             MesStatus = 2 
            ,MesActualStartTime = GETDATE()
         WHERE
             ErpWorkOrderNumber  = @WorkOrderNumber
         AND MesWorkOrderVersion = @WorkOrderVersion;
     END

     --3. 更新当下工序的实际产出数量, 
     -- 这里的操作 "不要" 和下面的 "本工序产出完成" 的另一个条件分支合并起来, 
     -- 因为, 可能会有订单数量为 "1" 情况, 这样就可能一次产量输出事件就完成了工单而导致工单号码和版本号密码没有机会更新
     -- 这样写的方法会多执行一次数据表的更新操作, 工序表很小, 因此问题不大.
     UPDATE Mes_Process_List
     SET    
          WorkOrderNumber  = @WorkOrderNumber
         ,WorkOrderVersion = @WorkOrderVersion
         ,FinishQty        = @TagFinishQty
         ,PlanQty          = @PrsPlanQty
         ,ParamTime        = GETDATE() 
         ,ParamName        = @TagName   
         ,ParamValue       = @TagValue 
     WHERE 
          ProcessCode = @pProcessCode

     --本工序产出完成
     IF @PrsPlanQty <= @FinishQty 
     BEGIN
         UPDATE Mes_Process_List
         SET    
             FinishQty   = -1
            ,ParamTime   = GETDATE() 
            ,ParamName   = @TagName   
            ,ParamValue  = @TagValue 
         WHERE 
             ProcessCode = @pProcessCode

      -- 此处的需求有变化, 不需要进行完工更换产品需求的自动完成动作了.
      -- 新加入了一个页面, 其专门用于手动发送换更产品请求.
      -- 触发: 换更产品请求动作: 'CS', 'Cutover Send')
      -- 需要的步骤有: 1.找到本工序对应的TAG, 2.写入换更动作    
      
      --   DECLARE @BatchNo   AS VARCHAR(15); 
      --   EXEC usp_Mes_GetNewSerialNo_Output 'WIP2PLC','W2P', 10, @BatchNo OUTPUT;
      --
      --   INSERT INTO Mes_PLC_TransInterface( 
      --         BATCHNUM
      --       , PLCID
      --       , SOURCEID
      --       , ParamName
      --       , ParamType
      --       , ParamValue
      --       , OperateCommand
      --       , OperateUser
      --       , [Status])
      --   SELECT    
      --         @BatchNo
      --       , Mes_PLC_Parameters.PLCID
      --       , Mes_PLC_Parameters.ID
      --       , Mes_PLC_Parameters.ParamName
      --       , Mes_PLC_Parameters.ParamType            
      --       , CASE UPPER(Mes_PLC_Parameters.ParamType)   --此处电话和海亮确认不需要参数类型, MES都传送1值作为停机参数.
      --              WHEN 'WORD'  THEN '1'
      --              WHEN 'DWORD' THEN '1'
      --              WHEN 'BOOL'  THEN '1'
      --         END
      --       , Mes_PLC_Parameters.OperateCommand
      --       , 'MES'
      --       , 0          
      --   FROM 
      --       Mes_PLC_Parameters, Mes_PLC_List 
      --   WHERE 
      --       Mes_PLC_Parameters.PLCID = Mes_PLC_List.ID --因为加入了PLC ID的限制, 此Mes_PLC_List表其实完全可以不需要参与进来. 
      --   AND Mes_PLC_Parameters.ApplModel = 'CS'
      ---- AND Mes_PLC_List.GoodsCode = '0000000000'      --因为加入了PLC ID的限制, 因此这两个条件暂时不再需要
      ---- AND Mes_PLC_List.ProcessCode = @pProcessCode   --因为加入了PLC ID的限制, 因此这两个条件暂时不再需要
      --   AND MES_PLC_List.ID = ( SELECT PLC.ID          --这是基于假定: 同一个PLC只有一个何其计数对应的更换产品请求的控制参数, 有统一工序多个PLC同时存在的情况.
      --                           FROM Mes_PLC_List PLC  
      --                              , Mes_PLC_Parameters PARM 
      --                           WHERE 
      --                                PARM.PLCID = PLC.ID  --查找TAG
      --                            AND PARM.ParamName = @TagName
      --                            AND PLC.GoodsCode = '0000000000');

     END

     --更新订单产量
     IF @FinalFlag = 1
     BEGIN
         UPDATE MFG_WO_List
         SET MesFinishQty = @FinishQty
         WHERE
             ErpWorkOrderNumber  = @WorkOrderNumber
         AND MesWorkOrderVersion = @WorkOrderVersion
         AND MesStatus           <>3 ;
     END
        
     --结束工单
     IF  @FinalFlag = 1 AND @PrsPlanQty <= @FinishQty
     BEGIN
         --结束工单主记录 (后台有一个分钟级别的job, 可以根据状态把计件物料扣除的物料提供给接口表.)
         UPDATE MFG_WO_List
         SET 
              MesStatus = 3
             ,MesActualFinishTime = GETDATE()
         WHERE
             ErpWorkOrderNumber  = @WorkOrderNumber
         AND MesWorkOrderVersion = @WorkOrderVersion
         AND MesStatus           <>3 ;

         --把工序表里面所有涉及此订单的记录全部重置(因为, 有的物料拉动工序可能会没有计件产出的情况.)
         UPDATE Mes_Process_List
         SET    
              FinishQty  = -1
             ,ParamTime  = GETDATE() 
             ,ParamName  = @TagName   
             ,ParamValue = @TagValue                      
         WHERE 
             WorkOrderNumber  = @WorkOrderNumber
         AND WorkOrderVersion = @WorkOrderVersion;  --这里需要把所有和这个工单有关系的标致都要结单, 因为可能有物料拉动的工序在没有产量计数触发事件.
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
    ;
    
GO
