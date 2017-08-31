<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="SubPlanControl.aspx.cs" Inherits="LiNuoMes.Mfg.SubPlanControl" %>

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
                //    $('#areascontent').width($(window).width() - 20);
                    $('#gridTable').setGridWidth(($('#areascontent').width()) - 10);
                //    $('#gridTable').setGridHeight($('#areascontent').height() - 200);
                }, 200);
            });

            InitPage();

            $(document).delegate(':text', "focus",
                function () {
                    $(this).select();
                    $(this).css("font-size:14px;");
                });

            $('#WorkOrderNumber').bind('keypress', function (event) {
                if (event.keyCode == "13") {
                    $('#btn_Search').trigger("click");
                }
            });

            $("#btn_Search").click(function () {
                var WorkOrderNumber = $("#WorkOrderNumber").val();
                var PlanDate = $("#PlanDate").val();

                if (WorkOrderNumber == undefined) {
                    WorkOrderNumber = "";
                }
                if (PlanDate == undefined) {
                    PlanDate = "";
                }

                WorkOrderNumber = WorkOrderNumber.toUpperCase().trim();

                $("#gridTable").jqGrid('setGridParam', {
                    postData: {
                        "WorkOrderNumber": WorkOrderNumber,
                        "PlanDate": PlanDate
                    }
                }).trigger('reloadGrid');
            });

            $("#btn_Return").click(function () {
                window.location.href = "./PlanControl.aspx";
            });

        });

        function InitPage() {
            var panelwidth = $('#areascontent').width();
            var strBtnStyle = "cursor:pointer;margin-left:5px;font-weight:700;padding:.2em .6em .3em;font-size:14px;";
            var $gridTable = $('#gridTable');
            $gridTable.jqGrid({
                url: "./GetSetMfg.ashx",
                postData: {
                    "Action": "MFG_WO_LIST_SUBPLAN"
                },
                datatype: "json",
                height: $('#areascontent').height() - 200,
                width: $('#areascontent').width,
                rowNum: -1,
                jsonReader: {
                    repeatitems: false,   //此两个参数影响了是否刷新之后高亮选中记录: 如果直接设定为true, 则无论id项设定与否都可以实现高亮选中
                    id: "ID"              //此两个参数影响了是否刷新之后高亮选中记录: 需要设定为唯一字段即可,如果设定为0值, 则需要repeatitems为true才可以.
                },
                colModel: [
                    { label: 'ID', name: 'ID', hidden: true },
                    { label: '序号', name: 'InturnNumber', index: 'InturnNumber', width: panelwidth * 0.02, align: 'center', sortable: false },
                    { label: '订单编号', name: 'WorkOrderNumber', index: 'WorkOrderNumber', width: panelwidth * 0.08, align: 'center', sortable: false },
                    { label: '产品物料编码', name: 'GoodsCode', index: 'GoodsCode', width: panelwidth * 0.15, align: 'center', sortable: false },
                    {
                        label: '订单类型', name: 'WorkOrderType', index: 'WorkOrderType', width: panelwidth * 0.06, align: 'center', sortable: false,
                        formatter: function (cellvalue, options, rowObject) {
                            return  cellvalue == "0" ? "正常订单"
                                  : cellvalue == "1" ? "下线补单"
                                  : "";
                        }
                    },
                    { label: '计划开始时间', name: 'PlanStartTime', index: 'PlanStartTime', width: panelwidth * 0.12, align: 'center', sortable: false },
                    { label: '计划完成时间', name: 'PlanFinishTime', index: 'PlanFinishTime', width: panelwidth * 0.12, align: 'center', sortable: false },
                    { label: '订单数量', name: 'PlanQty', index: 'PlanQty', width: panelwidth * 0.04, align: 'center', sortable: false },
                    { label: '报废数量', name: 'DiscardQty', index: 'DiscardQty', width: panelwidth * 0.04, align: 'center', sortable: false },
                    { label: '铜排气密性检测<br>未完工数', name: 'LeftQty1', index: 'LeftQty1', width: panelwidth * 0.06, align: 'center', sortable: false },
                    { label: '板芯气密性检测<br>未完工数', name: 'LeftQty2', index: 'LeftQty2', width: panelwidth * 0.06, align: 'center', sortable: false },
                    { label: '板芯装配<br>未完工数', name: 'LeftQty3', index: 'LeftQty3', width: panelwidth * 0.06, align: 'center', sortable: false },
                    { label: '终检(预装压条)<br>未完工数', name: 'LeftQty4', index: 'LeftQty4', width: panelwidth * 0.06, align: 'center', sortable: false },

                    {
                        label: '操 作', width: panelwidth * 0.15, align: 'center', sortable: false,
                        formatter: function (cellvalue, options, rowObject) {
                            var strEnableCreate = "";
                            var strEnableCheck = "";
                            var str = "";
                            if (rowObject.SubPlanFlag != "0" || rowObject.Status != "3") {
                                strEnableCreate = "disabled";
                            }

                            if (rowObject.SubPlanFlag == "0") {
                                strEnableCheck = "disabled";
                            }

                            str += '<button ' + strEnableCreate + ' onclick=\"onCreateSubWO(     \'' + rowObject.ID + '\')\" class=\"btn btn-success\" style=\"' + strBtnStyle + '\"><i class="fa fa-plus"></i>创建下线补单</button>';
                            str += '<button ' + strEnableCheck  + ' onclick=\"onCheckUnPlanedMTL(\'' + rowObject.WorkOrderNumber + '\',\'' + rowObject.WorkOrderVersion + '\')\" class=\"btn btn-success\" style=\"' + strBtnStyle + '\"><i class="fa fa-edit"></i>计划外领料单</button>';
                            return str;
                        }
                    },
                ],
                shrinkToFit: true,
                autowidth: true,
                scroll: true,
                multiselect: false,
                gridview: true,
                onSelectRow: function (rowid) {
                    selectedRowIndex = $("#gridTable").jqGrid("getGridParam", "selrow");
                },
                gridComplete: function () {
                    $("#gridTable").setSelection(selectedRowIndex, true);
                }
            });

        }

        function onCreateSubWO(WoId) {
            window.location.href = "./SubPlanConfirm.aspx?WoId=" + WoId;
        }

        function onCheckUnPlanedMTL(WorkOrderNumber, WorkOrderVersion) {
            window.location.href = "./UnPlanedMaterial.aspx?WorkOrderNumber=" + WorkOrderNumber + "&WorkOrderVersion=" + String(parseInt(WorkOrderVersion) + 1);
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
                                    <th><i class="fa fa-plus fa-lg" style="padding-right: 5px;"></i><strong style="font-size:20px">补单</strong></th>
                                    <td></td>
                                </tr>
                            </table>
                        </div>
                        <div class="panel-body" style="text-align:left">
                            <table class="form" border="0" style="width:100%">
                                <tr>
                                    <td class="formTitle" style="width:180px;font-weight:bold;text-align:right">订单编号:</td>                                    
                                    <td class="formValue">
                                        <input type="text" class="form-control" id="WorkOrderNumber" placeholder="订单编号">
                                    </td>                                    
                                    <td class="formTitle" style="width:180px;font-weight:bold;text-align:right">排程日期:</td>                                    
                                    <td class="formValue">
                                        <input type="text" readonly="true" id="PlanDate" onFocus="WdatePicker({dateFmt:'yyyy-MM-dd'})" class="Wdate timeselect" placeholder="排程日期">
                                    </td>                                    
                                    <td class="formValue" style="text-align:right">                                           
                                        <a id="btn_Search" class="btn btn-primary"><i class="fa fa-search"></i>查询 / 刷新</a>
                                        <a id="btn_Return" class="btn btn-primary"><i class="fa fa-reply"></i>返回 生产排程</a>
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
        *{
            font-size:15px; 
         }

        @media screen and (max-width: 1400px) { 
           .formTitle {
               font-size:15px;
               width:180px;
           } 

           .form-control {
               font-size:15px;
               width:240px !important;
               height:30px;
               margin-left:5px;
               margin-right:5px;
           }

           #form1{
               margin:0px 0px 0px 5px;
           }
       } 
       @media screen and (min-width: 1400px) { 
          .formTitle {
              font-size:20px;
              width:180px;
          } 
          .form-control {
               font-size:20px;
               width:240px !important;
               height:30px;
               margin-left:5px;
               margin-right:5px;
           }
           #form1{
               margin: 0px 0px 0px 5px;
           }
       } 
     </style>
    
</body>
</html>
