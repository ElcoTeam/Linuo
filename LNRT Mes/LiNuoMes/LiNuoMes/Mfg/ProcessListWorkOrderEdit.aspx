<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ProcessListWorkOrderEdit.aspx.cs" Inherits="LiNuoMes.Mfg.ProcessListWorkOrderEdit" %>

<!DOCTYPE html>

<html>
<head>
<title>力诺瑞特平板集热器</title>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="renderer" content="webkit">
    
    <script src="../Content/scripts/jquery-1.11.1.min.js"></script>
    <script src="../Content/scripts/bootstrap/bootstrap.min.js"></script>
    
    <script src="../js/pdfobject.js" type="text/javascript"></script>
    <link href="../Content/scripts/plugins/jquery-ui/jquery-ui.min.css" rel="stylesheet" />
    <script src="../Content/scripts/plugins/jquery-ui/jquery-ui.min.js"></script>
    <!-- Bootstrap -->
    <link rel="stylesheet" type="text/css" href="../css/bootstrap.min.css" />
    <link href="../Content/styles/font-awesome.min.css" rel="stylesheet" />
    <link href="../css/learun-ui.css" rel="stylesheet" />
    <link href="../Content/adminLTE/css/index.css" rel="stylesheet" />
    <link href="../Content/scripts/plugins/jqgrid/jqgrid.css" rel="stylesheet" />
    <link rel="Shortcut icon" href="../images/favicon.ico" />
    <link href="../Content/styles/learun-ui.css" rel="stylesheet" />
    <link href="../css/my.css" rel="stylesheet" media="screen">
    
    <script src="../Content/scripts/plugins/dialog/dialog.js"></script>
    <script src="../Content/adminLTE/index.js"></script>
    <script src="../Content/scripts/plugins/jqgrid/grid.locale-cn.js"></script>
    <script src="../Content/scripts/plugins/jqgrid/jqgrid.min.js"></script>
    <script src="../Content/scripts/utils/learun-ui.js"></script>
    <script src="../Content/scripts/utils/learun-form.js"></script>
    
    <script src="../BaseConfig/GetSetBaseConfig.js"></script>
     <script>
         var selectedRowIndex = 0;
         var ProcId = "";
         var OPtype = "";
         $(function () {
             $('#areascontent').height($(window).height() - 10);
             InitPage();
             InitData();
        });

        function InitPage() {
            var $gridTable0 = $('#gridTable');
            $gridTable0.jqGrid({
                url: "./GetSetMfg.ashx",
                postData: { Action: "MFG_WO_LIST" },
                datatype: "json",
                height: $('#areascontent').height() - 40,
                width: $('#areascontent').width,
                rowNum: -1,
                jsonReader: {
                    repeatitems: false,   //此两个参数影响了是否刷新之后高亮选中记录: 如果直接设定为true, 则无论id项设定与否都可以实现高亮选中
                    id: "ID"              //此两个参数影响了是否刷新之后高亮选中记录: 需要设定为唯一字段即可,如果设定为0值, 则需要repeatitems为true才可以.
                },
                colModel: [
                    { label: 'ID',  name: 'ID', hidden: true },
                    { label: '序号', name: 'InturnNumber', index: 'InturnNumber', width: 40, align: 'center', sortable: false },
                    { label: '订单编号', name: 'WorkOrderNumber', index: 'WorkOrderNumber', width: 110, align: 'center', sortable: false },
                    { label: '产品物料编码', name: 'GoodsCode', index: 'GoodsCode', width: 120, align: 'center', sortable: false },
                    { label: '产品物料描述', name: 'GoodsDsca', index: 'GoodsDsca', width: 350, align: 'center', sortable: false },
                    { label: '订单类型', name: 'WorkOrderType', index: 'WorkOrderType', width: 80, align: 'center', sortable: false,
                        formatter: function (cellvalue, options, rowObject) {
                            return  cellvalue == "0" ? "正常订单"
                                  : cellvalue == "1" ? "下线补单"
                                  : "";
                        }
                    },
                  //  { label: '计划开始时间', name: 'PlanStartTime', index: 'PlanStartTime', width: 150, align: 'center', sortable: false },
                  //  { label: '计划完成时间', name: 'PlanFinishTime', index: 'PlanFinishTime', width: 150, align: 'center', sortable: false },
                    { label: '订单数量', name: 'PlanQty', index: 'PlanQty', width: 50, align: 'center', sortable: false },
                    { label: '完成数量', name: 'FinishQty', index: 'FinishQty', width: 50, align: 'center', sortable: false },
                    {
                        label: '订单状态', name: 'Status', index: 'Status', width: 88, align: 'center', sortable: false,
                        formatter: function (cellvalue, options, rowObject) {
                            return  cellvalue == "0" ? "待生产"
                                  : cellvalue == "1" ? "产前调整中"
                                  : cellvalue == "2" ? "生产进行中"
                                  : cellvalue == "3" ? "已完成"
                                  : "";                            
                        }
                    }
                ],
                shrinkToFit: false,
                autowidth: true,
                scroll: true,
                gridview: true,
                multiselect: true,  
                multiboxonly:true ,  
                beforeSelectRow: function () {
                    $("#gridTable").jqGrid('resetSelection');
                    return (true);
                },
                onSelectRow: function (rowid) {
                    selectedRowIndex = $("#gridTable").jqGrid("getGridParam", "selrow");
                },
                gridComplete: function () {
                    $("#cb_" + $("#gridTable")[0].id).hide();
                    $("#gridTable").setSelection(selectedRowIndex, true);
                }
            });
        }

        function InitData() {
            ProcId = request('ProcId');
            OPtype = request('OPtype');
        }

        function AcceptClick(grid) {
            if (selectedRowIndex == 0) {
                dialogMsg("请选择要设定的工单!", -1);
                return;
            }

            $.ajax({
                url: "GetSetMfg.ashx",
                data: {
                    "Action": "MFG_PROCESS_LIST_WO_UPDATE",
                    "WoId": selectedRowIndex,
                    "ProcId": ProcId,
                    "OPtype": OPtype
                },
                async: true,
                type: "post",
                datatype: "json",
                success: function (data) {
                    Loading(false);
                    data = JSON.parse(data);
                    if (data.result == "success") {
                        window.parent.$('#gridTable').trigger("reloadGrid");
                        dialogMsg("修改数据保存成功", 1);
                        dialogClose();
                    }
                    else if (data.result == "failed") {
                        dialogMsg(data.msg, -1);
                    }
                },
                error: function (XMLHttpRequest, textStatus, errorThrown) {
                    Loading(false);
                    dialogMsg(errorThrown, -1);
                },
                beforeSend: function () {
                    Loading(true, "正在保存数据");
                },
                complete: function () {
                    Loading(false);
                }
            });
        }

        function request(name) {
            var reg = new RegExp("(^|&)" + name + "=([^&]*)(&|$)");
            var r = window.location.search.substr(1).match(reg);
            if (r != null) return unescape(r[2]); return null;
        }

        
    </script>
</head>
<body data-spy="scroll" data-target=".navbar-example" id="body1" class="body">
    <!--主体-->
    <div id="areascontent" style="margin:0px 5px 0px 5px; margin-bottom: 0px; overflow: auto;">
        <div class="gridPanel">
            <table id="gridTable"></table>
        </div>
    </div>

    <style>
        *{
            font-size:15px; 
         }

        @media screen and (max-width: 1400px) { 
           .formTitle {
               font-size:15px;
               width:200px;
           } 
           #form1{
               margin:0px 0px 0px 5px;
           }
       } 
       @media screen and (min-width: 1400px) { 
          .formTitle {
              font-size:30px;
              width:300px;
          } 
           #form1{
               margin: 0px 0px 0px 5px;
           }
       } 
     </style>
    
</body>
</html>
