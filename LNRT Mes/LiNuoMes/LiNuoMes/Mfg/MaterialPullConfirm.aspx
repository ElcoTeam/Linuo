<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="MaterialPullConfirm.aspx.cs" Inherits="LiNuoMes.Mfg.MaterialPullConfirm" %>

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
        $(function () {
           
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
            $("#Status").val("1");

            $("#btn_Search").click(function () {
                if (!$("#content").hasClass("active")) {
                    $("#content").addClass("active")

                } else {
                    $("#content").removeClass("active")

                }
            });

            GetGrid();
            CreateSelect();
        });

        //加载表格
        function GetGrid() {
            var selectedRowIndex = 0;
            var $gridTable = $('#gridTable');
            var Status = $("#Status").val();
            $gridTable.jqGrid({
                url: "GetMaterialConfirm.ashx",
                datatype: "json",
                postData: {
                    Status: Status
                },
                height: $(window).height() - 350,
                colModel: [
                     { label: '主键', name: 'ID', hidden: true },
                    {
                        label: '订单编号', name: 'WorkOrderNumber', index: 'WorkOrderNumber', width: 100, align: 'left'
                    },
                    {
                        label: '订单类型', name: 'WorkOrderVersion', index: 'WorkOrderVersion', width: 80, align: 'left',
                        formatter: function (cellvalue, options, rowObject) {
                            if (cellvalue == 0) {
                                return '正常订单';
                            }
                            else {
                                return '补单订单';
                            }
                        }
                    },
                    {
                        label: '下一订单编号', name: 'NextWorkOrderNumber', index: 'NextWorkOrderNumber', width: 100, align: 'left'
                    },
                    { label: '下一订单计划产量', name: 'NextWOPlanQty', index: 'NextWOPlanQty', width: 50, align: 'left' },
                    { label: '已经响应数量', name: 'ActionTotalQty', index: 'ActionTotalQty', width: 50, align: 'left' },
                    { label: '工序名称', name: 'Procedure_Name', index: 'Procedure_Name', width: 100, align: 'left' },
                    { label: '物料编号', name: 'ItemNumber', index: 'ItemNumber', width: 120, align: 'left' },
                    { label: '物料描述', name: 'ItemDsca', index: 'ItemDsca', width: 200, align: 'left' },
                    { label: '需求数量', name: 'Qty', index: 'Qty', width: 50, align: 'left' },
                    { label: '拉动时间', name: 'PullTime', index: 'PullTime', width: 180, align: 'left' },
                    {
                        label: '发送情况', name: 'Status', index: 'Status', width: 80, align: 'left',
                        formatter: function (cellvalue, options, rowObject) {
                            if (cellvalue == 0) {
                                return '待响应';
                            }
                            else if (cellvalue == 1) {
                                return '待确认';
                            }
                            else if (cellvalue == 2) {
                                return '已完成';
                            }
                            else if (cellvalue == -2) {
                                return '已删除';
                            }
                        }
                    },
                    { label: '响应数量', name: 'ActionQty', index: 'ActionQty', width: 50, align: 'left' },
                    { label: '响应时间', name: 'ActionTime', index: 'ActionTime', width: 180, align: 'left' },
                    { label: '响应人', name: 'ActionUser', index: 'ActionUser', width: 70, align: 'left' },
                    { label: '确认时间', name: 'ConfirmTime', index: 'ConfirmTime', width: 180, align: 'left' },
                    { label: '确认人', name: 'ConfirmUser', index: 'ConfirmUser', width: 70, align: 'left' },
                    {
                        label: '超时', name: 'OTFlag', index: 'OTFlag', width: 70, align: 'left',
                        formatter: function (cellvalue, options, rowObject) {
                            if (cellvalue == 0) {
                                return '未超时';
                            }
                            else if (cellvalue == 1) {
                                return '已超时';
                            }
                        }
                    },
                    {
                        label: '操作', name: 'Status', index: 'Status', width: 80, align: 'center',
                        formatter: function (cellvalue, options, rowObject) {
                            if (cellvalue == 1) {
                                console.log(cellvalue);
                                return '<span onclick=\"btn_enabled(\'' + rowObject[0] + '\')\" class=\"label label-danger\" style=\"cursor: pointer;\">确认</span>';
                            }
                            else {
                                console.log(cellvalue);
                                return '';
                            }
                        }
                    },
                    
                ],
                viewrecords: true,
                rowNum: 50,
                rowList: [50, 100, 150],
                pager: "#gridPager",
                sortname: 'WorkOrderNumber asc',
                rownumbers: true,
                rownumWidth: 50,
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

            //查询事件
            $("#lr_btn_querySearch").click(function () {
                var orderno = $("#orderno").val();
                var materialCode = $("#materialcode").val();
                var produce = $("#produce").val();
                var Status = $("#Status").val();
                var PullTimeStart = $("#PullTimeStart").val();
                var PullTimeEnd = $("#PullTimeEnd").val();
                var OTFlag = $("#OTFlag").val();
                var ActionTimeStart = $("#ActionTimeStart").val();
                var ActionTimeEnd = $("#ActionTimeEnd").val();
                var ActionUser = $("#ActionUser").val();
                var ConfirmTimeStart = $("#ConfirmTimeStart").val();
                var ConfirmTimeEnd = $("#ConfirmTimeEnd").val();
                var ConfirmUser = $("#ConfirmUser").val();

                $gridTable.jqGrid('setGridParam', {
                    postData: {
                        Orderno: orderno, MaterialCode: materialCode, Produce: produce,
                        Status: Status, PullTimeStart: PullTimeStart, PullTimeEnd: PullTimeEnd,
                        OTFlag: OTFlag, ActionTimeStart: ActionTimeStart, ActionTimeEnd: ActionTimeEnd,
                        ActionUser: ActionUser, ConfirmTimeStart: ConfirmTimeStart, ConfirmTimeEnd: ConfirmTimeEnd,
                        ConfirmUser: ConfirmUser
                    }, page: 1
                }).trigger('reloadGrid');

            });
            
            $gridTable.jqGrid('setLabel', 'rn', '序号', {
                'text-align': 'center'
            });
        }
        //构造select
        function CreateSelect() {
            $("#produce").empty();
            var optionstring = "";
            $.ajax({
                url: "MaterialPullResponse.aspx/GetProduceInfo",
                type: "post",
                dataType: "json",
                data: "{deviceid:''}",
                contentType: "application/json;charset=utf-8",
                success: function (data) {
                    var data1 = eval('(' + data.d + ')');
                    var i = 0;
                    for (i in data1) {
                        optionstring += "<option value=\"" + data1[i].ProcessCode + "\" >" + data1[i].ProcessName.trim() + "</option>";
                        //optionstring1 += "<option value=\"" + data1[i].Station_Name + "\" >" + data1[i].Station_Name.trim() + "</option>";
                    }
                    $("#produce").html("<option value=''>请选择...</option> " + optionstring);
                },
                error: function (msg) {
                    dialogMsg("数据访问异常", -1);
                }
            });

        }


        //确认
        function btn_enabled(keyValue) {
            if (keyValue == undefined) {
                keyValue = $("#gridTable").jqGridRowValue("ID");
            }
            if (keyValue) {
                 Loading(true, "正在保存数据...");
                 window.setTimeout(function () {
                     $.ajax({
                         url: "MaterialPullConfirm.aspx/ConfirmPullInfo",
                         data: "{ID:'" + keyValue + "'}",
                         type: "post",
                         dataType: "json",
                         contentType: "application/json;charset=utf-8",
                         success: function (data) {
                             if (data.d == "success") {
                                 Loading(false);
                                 dialogMsg("确认成功", 1);
                                 $("#gridTable").trigger("reloadGrid");
                             }
                             else if (data.d == "falut") {
                                 dialogMsg("确认失败", -1);
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
                 }, 500);           
            } else {
                dialogMsg('您没有选择任何数据！', 0);
            }
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
                        <div class="panel-heading"><i class="fa fa-bar-chart fa-lg" style="padding-right: 5px;"></i><strong style="font-size:20px;">物料拉动确认</strong></div>
                         <div class="lr-layout-tool">
                              
                                   <div class="lr-layout-tool-left">
                                       <div class="lr-layout-tool-item">
                                           <span class="formTitle">发送情况：</span>
                                           <select class="form-control" id="Status">
                                            <option value=''>请选择...</option>
                                            <option value='0'>待响应</option>
                                            <option value='1'>待确认</option>
                                            <option value='2'>已完成</option>
                                           </select>
                                       </div>
                                       <div class="lr-layout-tool-item" id="multiple_condition_query_item">
                                            <div id="multiple_condition_query" class="lr-query-wrap">
                                                <div class="lr-query-btn" id="btn_Search" style="font-size:10px;">
                                                    <i class="fa fa-search"></i>&nbsp;多条件查询
                                                </div>
                                                <div class="lr-query-content" style="width:800px;height:320px;" id="content">
                                                    <div class="lr-query-formcontent" style="display:block"></div>
                                                    <div class="lr-query-arrow">
                                                        <div class="lr-query-inside"></div>
                                                    </div>
                                                    <div class="lr-query-content-bottom">
                                                         <%--<a id="lr_btn_queryReset" class="btn btn-default">&nbsp;重&nbsp;&nbsp;置</a>--%>
                                                         <a id="lr_btn_querySearch" class="btn btn-primary">&nbsp;查&nbsp;&nbsp;询</a>
                                                    </div>
                                                     <div class=" col-xs-12 lr-form-item">                                                        <div class="lr-form-item-title">订单编号：</div>                                                        <input type="text" class="form-control" id="orderno" placeholder="请输入订单编号">                                                    </div>                                                    <div class=" col-xs-12 lr-form-item">                                                        <div class="lr-form-item-title">物料编号：</div>                                                        <input type="text" class="form-control" id="materialcode" placeholder="请输入物料编号">                                                    </div>                                                    <div class=" col-xs-12 lr-form-item">                                                        <div class="lr-form-item-title">工序名称：</div>                                                        <select class="form-control" id="produce"></select>                                                    </div>                                                                                                        <div class=" col-xs-12 lr-form-item">                                                        <div class="lr-form-item-title">是否超时：</div>                                                        <select class="form-control" id="OTFlag">
                                                                <option value=''>请选择...</option>
                                                                <option value='1'>是</option>
                                                                <option value='0'>否</option>
                                                        </select>                                                    </div>
                                                    <div class=" col-xs-12 lr-form-item">                                                         <div class="lr-form-item-title">响应人：</div>                                                         <input type="text" class="form-control" id="ActionUser" placeholder="请输入响应人">                                                    </div>
                                                    <div class=" col-xs-12 lr-form-item">                                                         <div class="lr-form-item-title">确认人：</div>                                                         <input type="text" class="form-control" id="ConfirmUser" placeholder="请输入确认人">                                                    </div>
                                                    <div class=" col-xs-12 lr-form-item">                                                        <div class="lr-form-item-title">拉动时间：</div>                                                        <input id="PullTimeStart"  type="text" onFocus="WdatePicker({maxDate:'#F{$dp.$D(\'ActionTimeEnd\')}'})" class="Wdate form-control" style="display:inline;" />&nbsp;至&nbsp;
                                                        <input id="PullTimeEnd"  type="text" onFocus="WdatePicker({minDate:'#F{$dp.$D(\'ActionTimeStart\')}'})" class="Wdate form-control" style="display:inline;"/>                                                     </div>
                                                    <div class=" col-xs-12 lr-form-item">                                                        <div class="lr-form-item-title">响应时间：</div>                                                        <input id="ActionTimeStart"  type="text" onFocus="WdatePicker({maxDate:'#F{$dp.$D(\'ActionTimeEnd\')}'})" class="Wdate form-control" style="display:inline;" />&nbsp;至&nbsp;
                                                        <input id="ActionTimeEnd"  type="text" onFocus="WdatePicker({minDate:'#F{$dp.$D(\'ActionTimeStart\')}'})" class="Wdate form-control" style="display:inline;"/>                                                     </div>
                                                    <div class=" col-xs-12 lr-form-item">                                                        <div class="lr-form-item-title">确认时间：</div>                                                        <input id="ConfirmTimeStart"  type="text" onFocus="WdatePicker({maxDate:'#F{$dp.$D(\'ActionTimeEnd\')}'})" class="Wdate form-control" style="display:inline;" />&nbsp;至&nbsp;
                                                        <input id="ConfirmTimeEnd"  type="text" onFocus="WdatePicker({minDate:'#F{$dp.$D(\'ActionTimeStart\')}'})" class="Wdate form-control" style="display:inline;"/>                                                     </div>
                                                </div>
                                            </div>
                                       </div>
                                    </div>
                           </div>
                    </div>
                </div>
            </div>
         </div>
         <div class="rows" style="margin-top:3.5%; overflow: hidden; ">
             
              <div class="gridPanel">
                   <table id="gridTable"></table>
                   <div id="gridPager"></div>
              </div>
         </div>
    </div>
   
</body>
</html>



