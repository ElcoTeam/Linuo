<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="UnPlanedMaterial.aspx.cs" Inherits="LiNuoMes.Mfg.UnPlanedMaterial" %>

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
    <link href="../Content/scripts/plugins/printTable/learun-report.css" rel="stylesheet" />
    <link href="../Content/styles/learun-ui.css" rel="stylesheet" />
    <link href="../css/my.css" rel="stylesheet" media="screen">
    <script src="../Content/scripts/plugins/dialog/dialog.js"></script>
    <script src="../Content/adminLTE/index.js"></script>
    <script src="../Content/scripts/plugins/jqgrid/grid.locale-cn.js"></script>
    <script src="../Content/scripts/plugins/jqgrid/jqgrid.min.js"></script>
    <script src="../Content/scripts/utils/learun-ui.js"></script>
    <script src="../Content/scripts/utils/learun-form.js"></script>
     <script src="../Content/scripts/plugins/printTable/jquery.printTable.js"></script>

    <script>
        var WorkOrderNumber = "";
        var WorkOrderVersion = "";
        $(function () {
            WorkOrderNumber = request('WorkOrderNumber');
            WorkOrderVersion = request('WorkOrderVersion');
            if ($('#areascontent').height() > $(window).height() - 20) {
                $('#areascontent').css("margin-right", "0px");
            }
            $('#areascontent').height($(window).height()-106);
            var areaheight = $("#areascontent").height();
            $(window).resize(function (e) {
                window.setTimeout(function () {
                    $('#gridTable').setGridWidth(($('.gridPanel').width()));
                    $('#areascontent').height($(window).height()-106);
                }, 200);
            });
            GetGrid();
            InitalControl();
        });

        //加载表格
        function GetGrid() {
            var selectedRowIndex = 0;
            var panelwidth = $('.gridPanel').width();
            var $gridTable = $('#gridTable');
            $gridTable.jqGrid({
                url: "GetUnPlanedMaterial.ashx",
                postData: { Action: "UnPlanedMaterialListInfo", WorkOrderNumber: WorkOrderNumber, WorkOrderVersion: WorkOrderVersion },
                datatype: "json",
                height: $('#areascontent').height() *0.7,
                colModel: [
                    {
                        label: '工序', name: 'ProcessName', index: 'ProcessName', width: panelwidth * 0.25, align: 'center', sortable: false
                    },
                    { label: '物料编码', name: 'ItemNumber', index: 'ItemNumber', width: panelwidth * 0.3, align: 'center', sortable: false },
                    { label: '剩余数量', name: 'LeftQty', index: 'LeftQty', width: panelwidth * 0.25, align: 'center', sortable: false },
                    { label: '需求数量', name: 'Qty', index: 'Qty', width: panelwidth * 0.25, align: 'center', sortable: false },
                    //{ label: '仓库', name: 'WHLocation', hidden: true },
                    //{ label: '工作中心', name: 'WorkSite', hidden: true },
                ],
                viewrecords: true,
                rowNum: "10000",
                shrinkToFit: false,
                autowidth: true,
                scrollrows: true,
                gridview: true,
                onSelectRow: function () {
                    selectedRowIndex = $("#" + this.id).getGridParam('selrow');
                },
                gridComplete: function () {
                    $("#" + this.id).setSelection(selectedRowIndex, false);
                }
            });
        }

        //初始化控件值
        function InitalControl() {
            $.ajax({
                url: "GetUnPlanedMaterial.ashx",
                data: {
                    "Action": "GetUnPlanedMaterial_Detail",
                    "WorkOrderNumber": WorkOrderNumber,
                    "WorkOrderVersion":WorkOrderVersion
                },
                type: "post",
                datatype: "json",
                success: function (data) {
                    data = JSON.parse(data);
                    $("#WorkOrderNumber").html(data.WorkOrderNumber);
                    $("#ItemNumber").html(data.ItemNumber);
                    $("#WorkOrderType").html('下线补单');
                    $("#Qty").html(data.MesPlanQty);
                    
                    Loading(false);
                }, beforeSend: function () {
                    Loading(true);
                }
            });
        }

        //打印
        function btn_print(event) {
            //try {
            //    $("#gridPanel").printTable();
            //} catch (e) {
            //    dialogMsg("Exception thrown: " + e, -1);
            //    //("Exception thrown: " + e);
            //}
            var WHLocation = $("#WHLocation").val();
            var WorkSite = $("#WorkSite").val();
            dialogOpen({
                id: "Form",
                title: '计划外领料单--打印',
                url: '../Mfg/UnPlanedMaterialPrint.aspx?actionname=1&WorkOrderNumber=' + WorkOrderNumber + '&WorkOrderVersion=' + WorkOrderVersion + '&WHLocation=' + WHLocation + '&WorkSite=' + WorkSite + '',
                width: "800px",
                height: "650px",
                callBack: function (iframeId) {
                    top.frames[iframeId].AcceptClick();
                }
            });
        }

        //导出
        function btn_export(event) {
            
            dialogOpen({
                id: "Form",
                title: '计划外领料单--导出',
                url: '../Mfg/UnPlanedMaterialPrint.aspx?actionname=2&WorkOrderNumber=' + WorkOrderNumber + '&WorkOrderVersion=' + WorkOrderVersion + '',
                width: "800px",
                height: "650px",
                callBack: function (iframeId) {
                   top.frames[iframeId].AcceptClick();
                }
            });
        }

        //返回
        function btn_back(event) {
            window.location.href = "./SubPlanControl.aspx";
        }
    </script>
</head>
<body data-spy="scroll" data-target=".navbar-example" id="body">
    <!--nav-->
    <div class="navbar navbar-inverse navbar-fixed-top" id="nav">
        
    </div>
    <!--end nav-->
   
    <!--导航栏-->
    <div class="yn jz container-fluid nav-bgn m0" id="menu_wrap">
      
    </div>
    <!--主体-->
    <div id="areascontent" style="margin:50px 10px 0 10px; margin-bottom: 0px; overflow: auto;">
         <div class="rows" style="margin-top:0.5%; margin-bottom: 0.8%; overflow: hidden;">
            <div style="float: left; width: 100%;">
                <div style="height:20%; border: 1px solid #e6e6e6; background-color: #fff;">
                    <div class="panel panel-default">
                        <div class="panel-heading"><i class="fa fa-bar-chart fa-lg" style="padding-right: 5px;"></i><strong style="font-size:20px;">计划外领料单</strong></div>
                        <div class="panel-body">
                            <table id="form1" class="form">
                                <tr>
                                    <th class="formTitle" style="width:250px;">订单编号：</th>
                                    <td class="formValue">
                                        <label id="WorkOrderNumber" class="form-control" style=" border: 0px;"></label>
                                        <%--<input type="text" class="form-control" id="WorkOrderNumber" readonly>--%>
                                    </td>
                                    <th class="formTitle" style="width:250px;">产品物料编码：</th>
                                    <td class="formValue">
                                        <label id="ItemNumber" class="form-control" style=" border: 0px;"></label>
                                        <%--<input type="text" class="form-control" id="ItemNumber" readonly>--%>
                                    </td>
                                </tr>
                                <tr>
                                    <th class="formTitle">订单类型：</th>
                                    <td class="formValue">
                                       <label id="WorkOrderType" class="form-control" style=" border: 0px;"></label>
                                       <%-- <input type="text" class="form-control" id="WorkOrderType" readonly>--%>
                                    </td>
                                    <th class="formTitle">订单数量：</th>
                                    <td class="formValue">
                                       <label id="Qty" class="form-control" style=" border: 0px;"></label>
                                       <%-- <input type="text" class="form-control" id="Qty" readonly>--%>
                                    </td>
                                </tr>
                                <tr>
                                    <th class="formTitle">仓库：</th>
                                    <td class="formValue">
                                       <%--<label id="WHLocation" class="form-control" style=" border: 0px;"></label>--%>
                                       <input type="text" class="form-control" id="WHLocation">
                                    </td>
                                    <th class="formTitle">工作中心：</th>
                                    <td class="formValue">
                                       <%--<label id="WorkSite" class="form-control" style=" border: 0px;"></label>--%>
                                       <input type="text" class="form-control" id="WorkSite">
                                    </td>
                                </tr>
                            </table>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        <div class="titlePanel">
        <div class="title-search">
           <div><strong style="font-size:15px;">计划外领料单</strong></div>
        </div>
        <div class="toolbar">
            <div class="btn-group">
                <a id="lr-print" class="btn btn-default" onclick="btn_print(event)"><i class="fa fa-print"></i>&nbsp;打印</a>
                <a id="lr-export" class="btn btn-default" onclick="btn_export(event)"><i class="fa fa-plus"></i>&nbsp;导出</a>
                <a id="lr-back" class="btn btn-default" onclick="btn_back(event)"><i class="fa fa-mail-reply"></i>&nbsp;返回</a>
            </div>
           
         </div>
         </div>
         <div class="ui-report"> 
         <div class="rows" style="margin-top:0.5%; overflow: hidden; ">
              <div class="gridPanel">
                   
                   <table id="gridTable"></table>
              </div>
              
         </div>
         </div>
    </div>

</body>
</html>


