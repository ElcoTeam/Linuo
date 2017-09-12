<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ProductRepairMan.aspx.cs" Inherits="LiNuoMes.Mfg.ProductRepairMan" %>

<!DOCTYPE html>

<html>
<head>
<title>力诺瑞特平板集热器</title>
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
    <script src="../My97DatePicker/WdatePicker.js"></script>
    <script>
        var selectedRowIndex = 0;
        $(function () {
            if ($('#areascontent').height() > $(window).height() - 20) {
                $('#areascontent').css("margin-right", "0px");
            }
            $('#areascontent').height($(window).height() - 106);
            var areaheight = $("#areascontent").height();
            $(window).resize(function (e) {
                window.setTimeout(function () {
                    $('#areascontent').height($(window).height() - 106);
                    $('#areascontent').width($(window).width() - 20);
                    $('#gridTable').setGridWidth(($('#areascontent').width()) - 10);
                    $('#gridTable').setGridHeight($('#areascontent').height() - 200);
                }, 200);
            });

            InitalMes();
            //InitPage();
        });

        function InitPage() {
            var panelwidth = $('#areascontent').width();
            var $gridTable = $('#gridTable');
            var RFID = $("#RFID").val();
            var WorkOrderNumber = $("#WorkOrderNumber").val();
            var GoodsCode = $("#GoodsCode").val();
            var AbnormalPoint = $("#AbnormalPoint").val();
            var AbnormalType = $("#AbnormalType").val();
            var RepairStatus = $("#RepairStatus").val();
            var FromTime = $("#FromTime").val();
            var ToTime = $("#ToTime").val();
            var RepairFromTime = $("#RepairFromTime").val();
            var RepairToTime = $("#RepairToTime").val();

            $gridTable.jqGrid({
                url: "./GetProductRepair.ashx",
                postData: {
                    "Action": "MFG_ProductRepairInfo",
                    "WorkOrderNumber": WorkOrderNumber,
                    "RFID": RFID,
                    "GoodsCode": GoodsCode,
                    "AbnormalPoint": AbnormalPoint,
                    "AbnormalType": AbnormalType,
                    "RepairStatus": RepairStatus,
                    "FromTime": FromTime,
                    "ToTime": ToTime,
                    "RepairFromTime": RepairFromTime,
                    "RepairToTime": RepairToTime
                },
                datatype: "json",
                height: $('#areascontent').height() * 0.7,
                colModel: [
                    { label: 'ID', name: 'ID', hidden: true },
                    { label: '序号', name: 'InturnNumber', index: 'InturnNumber', width: panelwidth * 0.03, align: 'center', sortable: false },
                    { label: '订单编号', name: 'WorkOrderNumber', index: 'WorkOrderNumber', width: panelwidth * 0.11, align: 'center', sortable: false },
                    { label: 'MES码', name: 'RFID', index: 'RFID', width: panelwidth * 0.17, align: 'center', sortable: false },
                    { label: '产品物料编码', name: 'GoodsCode', index: 'GoodsCode', width: panelwidth * 0.09, align: 'center', sortable: false },
                    {
                        label: '下线工序', name: 'AbnormalPoint', index: 'AbnormalPoint', width: panelwidth * 0.08, align: 'center', sortable: false,
                        formatter: function (cellvalue, options, rowObject) {
                            return  cellvalue == "1" ? "铜排气密性检测"
                                  : cellvalue == "2" ? "板芯气密性检测"
                                  : cellvalue == "3" ? "板芯装配"
                                  : cellvalue == "4" ? "终检(预装压条)"
                                  : "";
                        }
                    },
                    {
                        label: '下线类型', name: 'AbnormalType', index: 'AbnormalType', width: panelwidth * 0.06, align: 'center', sortable: false,
                        formatter: function (cellvalue, options, rowObject) {
                            return  cellvalue == "1" ? "补修"
                                  : cellvalue == "3" ? "未完工"
                                  : "";
                        }
                    },
                    { label: '下线时间', name: 'AbnormalTime', index: 'AbnormalTime', width: panelwidth * 0.16, align: 'center', sortable: false },
                    { label: '下线人员', name: 'AbnormalUser', index: 'AbnormalUser', width: panelwidth * 0.06, align: 'center', sortable: false },
                    {
                        label: '补修状态', name: 'RepairStatus', index: 'RepairStatus', width: panelwidth * 0.06, align: 'center', sortable: false,
                        formatter: function (cellvalue, options, rowObject) {
                            return  cellvalue == "0" ? "待补修"
                                  : cellvalue == "2" ? "已完成"
                                  : "";
                        }
                    },
                    { label: '补修时间', name: 'RepairTime', index: 'RepairTime', width: panelwidth * 0.14, align: 'center', sortable: false },
                    { label: '补修人员', name: 'RepairUser', index: 'RepairUser', width: panelwidth * 0.14, align: 'center', sortable: false },
                    {
                        label: '操 作', width: panelwidth * 0.14, align: 'center', sortable: false,
                        formatter: function (cellvalue, options, rowObject) {
                            console.log(rowObject);
                            if (rowObject.RepairStatus== '2') {
                                return '<span onclick=\"btn_search(\'' + rowObject.ID + '\')\" class=\"label label-success\" style=\"cursor: pointer;\"><i class="fa fa-eye"></i>查看</span>' + '<span onclick=\"btn_edit(\'' + rowObject.ID + '\')\" class=\"label label-success\" style=\"cursor: pointer;margin-left:10px;\"><i class="fa fa-edit"></i>修改</span>';
                            }
                            else if (rowObject.RepairStatus == '0') {
                                return '<span onclick=\"btn_search(\'' + rowObject.ID + '\')\" class=\"label label-success\" style=\"cursor: pointer;\"><i class="fa fa-eye"></i>查看</span>' + '<span onclick=\"btn_repair(\'' + rowObject.ID + '\')\" class=\"label label-success\" style=\"cursor: pointer;margin-left:10px;\"><i class="fa fa-edit"></i>补修</span>';
                            }
                        }
                    },

                ],
                shrinkToFit: true,
                autowidth: true,
                scroll: true,
                multiselect: false,
                gridview: true,
                rowNum: -1,
                onSelectRow: function (rowid) {
                    selectedRowIndex = $("#gridTable").jqGrid("getGridParam", "selrow");
                },
                gridComplete: function () {
                    $("#gridTable").setSelection(selectedRowIndex, true);
                }
            });

            //查询事件
            $("#btn_Search").click(function () {
                ReloadGrid();
                
            });
        }

        function InitalMes()
        {
            $.ajax({
                url: "ProductRepairMan.aspx/GetMesCode",
                type: "post",
                dataType: "json",
                data: "{deviceid:''}",
                contentType: "application/json;charset=utf-8",
                success: function (data) {
                    var data1 = eval('(' + data.d + ')');
                    $("#RFID").val(data1[0].MesCode);
                    InitPage();
                },
                error: function (msg) {
                    dialogMsg("数据访问异常", -1);
                }
            });
        }

        function ReloadGrid()
        {
            var RFID = $("#RFID").val();
            var WorkOrderNumber = $("#WorkOrderNumber").val();
            var GoodsCode = $("#GoodsCode").val();
            var AbnormalPoint = $("#AbnormalPoint").val();
            var AbnormalType = $("#AbnormalType").val();
            var RepairStatus = $("#RepairStatus").val();
            var FromTime = $("#FromTime").val();
            var ToTime = $("#ToTime").val();
            var RepairFromTime = $("#RepairFromTime").val();
            var RepairToTime = $("#RepairToTime").val();

            $gridTable.jqGrid('setGridParam',
                {
                    postData: {
                        "WorkOrderNumber": WorkOrderNumber,
                        "RFID": RFID,
                        "GoodsCode": GoodsCode,
                        "AbnormalPoint": AbnormalPoint,
                        "AbnormalType": AbnormalType,
                        "RepairStatus": RepairStatus,
                        "FromTime": FromTime,
                        "ToTime": ToTime,
                        "RepairFromTime": RepairFromTime,
                        "RepairToTime": RepairToTime
                    }
                }).trigger('reloadGrid');
        }
        //查看 1：查看
        function btn_search(equid) {
            if (equid == undefined) {
                equid = $("#gridTable").jqGridRowValue("ID");
            }
            console.log(equid);
            dialogOpen({
                id: "Form",
                title: '产品补修信息维护--查看',
                url: '../Mfg/ProductRepairDetailEdit.aspx?actionname=1&equid=' + equid + '',
                width: "750px",
                height: "650px",
                btn: null
            });
        }

        //补修  2：补修
        function btn_repair(equid) {
            if (equid == undefined) {
                equid = $("#gridTable").jqGridRowValue("ID");
            }
            dialogOpen({
                id: "Form",
                title: '产品补修信息维护--补修',
                url: '../Mfg/ProductRepairDetailEdit.aspx?actionname=2&equid=' + equid + '',
                width: "750px",
                height: "650px",
                callBack: function (iframeId) {
                    top.frames[iframeId].AcceptClick($("#gridTable"));
                }
            });
        }

        //修改  3: 修改
        function btn_edit(equid) {
            if (equid == undefined) {
                equid = $("#gridTable").jqGridRowValue("ID");
            }
            dialogOpen({
                id: "Form",
                title: '产品补修信息维护--修改',
                url: '../Mfg/ProductRepairDetailEdit.aspx?actionname=3&equid=' + equid + '',
                width: "750px",
                height: "650px",
                callBack: function (iframeId) {
                    top.frames[iframeId].AcceptClick($("#gridTable"));
                }
            });
        }
    </script>
</head>
<body data-spy="scroll" data-target=".navbar-example" id="body1" class="body">

    <!--nav-->
    <div class="navbar navbar-inverse navbar-fixed-top" id="nav"></div>
    <!--end nav-->
   
    <!--导航栏-->
    <div class="yn jz container-fluid nav-bgn m0" id="menu_wrap"></div>

    <!--主体-->
    <div id="areascontent" style="margin:50px 10px 0px 10px; margin-bottom: 0px; overflow: auto;">
         <div class="rows" style="margin-top:0.5%; margin-bottom: 0.8%; overflow: hidden;">
            <div style="float: left; width: 100%;">
                <div style="height:20%; border: 1px solid #e6e6e6; background-color: #fff;">
                    <div class="panel panel-default">
                        <div class="panel-heading" >
                            <table id="panelheading" border="0" style="width:100%">
                                <tr>
                                    <th><i class="fa fa-bar-chart fa-lg" style="padding-right: 5px;"></i><strong style="font-size:20px">产品补修管理</strong></th>
                                    <td></td>
                                </tr>
                            </table>
                        </div>
                        <div class="panel-body" style="text-align:left">
                            <table class="form" border="0" style="width:100%">
                                <tr>
                                    <th class="formTitle">MES码：</th>                                    
                                    <td class="formValue">
                                        <input type="text" class="form-control" id="RFID" placeholder="MES码">
                                    </td>                                   
                                    <th class="formTitle">订单编号:</th>                                    
                                    <td class="formValue">
                                        <input type="text" class="form-control" id="WorkOrderNumber" placeholder="订单编号">
                                    </td>  
                                </tr>
                                <tr>
                                    <th class="formTitle">产品物料编码:</th>                                    
                                    <td class="formValue">
                                        <input type="text" class="form-control" id="GoodsCode" placeholder="产品物料编码">
                                    </td>                                    
                                    <th class="formTitle">下线工序:</th>                                    
                                    <td class="formValue">
                                        <select class="form-control" id="AbnormalPoint">
                                            <option value ="">请选择...</option>
                                            <option value ="1">下线点1</option>
                                            <option value ="2">下线点2</option>
                                            <option value ="3">下线点3</option>
                                        </select>
                                    </td>  
                                </tr>
                                <tr>
                                    <th class="formTitle">下线类型:</th>                                    
                                    <td class="formValue">
                                        <select class="form-control" id="AbnormalType">
                                            <option value ="">请选择...</option>
                                            <option value ="1">补修</option>
                                            <option value ="2">未完工</option>
                                        </select>
                                    </td> 
                                    <th class="formTitle">补修状态:</th>                                    
                                    <td class="formValue">
                                        <select class="form-control" id="RepairStatus">
                                            <option value ="">请选择...</option>
                                            <option value ="1">待补修</option>
                                            <option value ="2">已完成</option>
                                        </select>
                                    </td>                                                                        
                                </tr>
                                <tr>                                  
                                    <th class="formTitle">下线时间:</th>                                    
                                    <td class="formValue" colspan="3">
                                        <input type="text" id="FromTime" onFocus="WdatePicker({dateFmt:'yyyy-MM-dd', readOnly:true})" class="Wdate timeselect"  placeholder="下线起始时间">至
                                        <input type="text" id="ToTime" onFocus="WdatePicker({dateFmt:'yyyy-MM-dd',readOnly:true})" class="Wdate timeselect" placeholder="下线结束时间">
                                    </td>                                    
                                </tr>
                                <tr>
                                    <th class="formTitle">补修时间：</th>
                                    <td class="formValue" colspan="3">
                                         <input type="text" id="RepairFromTime" onFocus="WdatePicker({dateFmt:'yyyy-MM-dd', readOnly:true})" class="Wdate timeselect"  placeholder="下线起始时间">至
                                         <input type="text" id="RepairToTime" onFocus="WdatePicker({dateFmt:'yyyy-MM-dd',readOnly:true})" class="Wdate timeselect" placeholder="下线结束时间">
                                    </td>
                                     <td class="formValue">
                                          <a id="btn_Search" class="btn btn-primary"><i class="fa fa-search"></i>&nbsp;查询</a>                        
                                     </td>
                                </tr>
                            </table>
                        </div>
                        <div class="rows" style="margin-top:0.5%; width:100%; overflow: hidden; ">
                              <div class="gridPanel">
                                   <table id="gridTable"></table>
                              </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
   <style>
       .form .form-control{
           width: 350px;
       }
       .timeselect{
           width: 350px;
       }
   </style>
</body>
</html>

