<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="SubPlanConfirm.aspx.cs" Inherits="LiNuoMes.Mfg.SubPlanConfirm" %>

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
        var WoId = "";
        var lastSelected = "";
        $(function () {
            WoId = request('WoId');

            if (WoId == undefined) {
                WoId = '0';
            }

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
                    $('#gridTable').setGridHeight($('#areascontent').height() - 300);
                }, 200);
            });

            InitPage0();
            InitPage1();
            $("#btn_Confirm").bind("click", onConfirm);
            $("#btn_Return").bind("click", onReturn);

            $(document).delegate('.editable',"focus",
                function () {
                //    $(this).select();
                });

            $(document).delegate(".editable", "blur", function () {
               // $("#gridTable").saveRow(selectedRowIndex);
            });

        });

        function InitPage0() {
            $.ajax({
                url: "GetSetMfg.ashx",
                data: {
                    "Action": "MFG_WO_LIST_DETAIL",
                    "WoId": WoId
                },
                type: "post",
                datatype: "json",
                success: function (data) {
                    data = JSON.parse(data);
                    var PlanQty = parseInt( data.DiscardQty) + parseInt(data.LeftQty1) + parseInt(data.LeftQty2);

                    $("#WorkOrderNumber").val(data.WorkOrderNumber);
                    $("#GoodsCode").val(data.GoodsCode);
                    $("#WorkOrderType").val(  "下线补单" );
                    $("#PlanQty").val(PlanQty);
                },

                error: function (msg) {
                    alert(msg.responseText);
                }
            });
        }

        function InitPage1() {
            var panelwidth = $('#areascontent').width();
            var $gridTable = $('#gridTable');
            $gridTable.jqGrid({
                url: "./GetSetMfg.ashx",
                postData: {
                    "Action": "WIP_ABNORMAL_MTL_SUMMARY",
                    "WoId": WoId
                },
                datatype: "json",
                height: $('#areascontent').height() - 300,
                width: $('#areascontent').width,
                rowNum: -1,
                jsonReader: {
                    repeatitems: false,   //此两个参数影响了是否刷新之后高亮选中记录: 如果直接设定为true, 则无论id项设定与否都可以实现高亮选中
                    id: "InturnNumber"    //此两个参数影响了是否刷新之后高亮选中记录: 需要设定为唯一字段即可,如果设定为0值, 则需要repeatitems为true才可以.
                },
                colModel: [
                    { label: 'ID', name: 'ID', hidden: true },
                    { label: '序号', name: 'InturnNumber', index: 'InturnNumber', width: panelwidth * 0.1, align: 'center', sortable: false },
                    { label: '工序', name: 'ProcessCode', index: 'ProcessCode', width: panelwidth * 0.15, align: 'center', sortable: false },
                    { label: '物料编码', name: 'ItemNumber', index: 'ItemNumber', width: panelwidth * 0.30, align: 'center', sortable: false },
                    { label: '物料描述', name: 'ItemDsca', index: 'ItemDsca', hidden: true, sortable: false },
                    { label: '物料单位', name: 'UOM', index: 'UOM',hidden: true },
                    {
                        label: '剩余数量', name: 'LeftQty', index: 'LeftQty', width: panelwidth * 0.15, align: 'center', sortable: false,
                        editable: true,
                        editrules: {
                            number: true,
                            custom: false,
                            required: false,
                            minValue: 0,
                            maxValue: 50000
                        }
                    },
                    {
                        label: '需求数量', name: 'RequireQty', index: 'RequireQty', width: panelwidth * 0.15, align: 'center', sortable: false,
                        editable: true,
                        editrules: {
                            number: true,
                            custom: false,
                            required: false,
                            minValue: 0,
                            maxValue: 50000
                        }
                    },
                    { label: '最新库存可用数量', name: 'InventoryQty', index: 'InventoryQty', width: panelwidth * 0.15, align: 'center', sortable: false },
                ],
                shrinkToFit: true,
                autowidth: true,
                scrollrows: true,
                gridview: true,
                beforeSelectRow: function (rowid) {
                    if (rowid && rowid !== selectedRowIndex) {
                         jQuery("#gridTable").saveRow(selectedRowIndex, true);
                    }
                    jQuery("#gridTable").editRow(rowid, true);
                    selectedRowIndex = rowid;
                    return false;
                },
                onSelectRow: function (rowid) { },
                gridComplete: function () {
                    var ids = $("#" + this.id).jqGrid().getDataIDs();
                    for (var i = ids.length - 1; i >= 0 ; i--)
                    {
                        $("#" + this.id).editRow(ids[i], true);
                    }
                }
            });
        }

        function onConfirm() {
            var ids = $("#gridTable").jqGrid().getDataIDs();
            for (var i = 0; i < ids.length; i++) {
                $("#gridTable").saveRow(ids[i], true);
            }

            var ListJason = GetUpdatedListJson();
            if (ListJason.length == 0) {
                return;
            }
            var ListJason = JSON.stringify(ListJason);

            $.ajax({
                url: "GetSetMfg.ashx",
                data: {
                    "Action": "MFG_WO_MTL_LIST_ADD_SUBPLAN",
                    "WoId": WoId,
                 // "PlanQty": PlanQty,
                    "ListJason": ListJason
                },
                async: true,
                type: "post",
                datatype: "json",
                success: function (data) {
                    Loading(false);
                    data = JSON.parse(data);
                    if (data.result == "success") {
                        dialogMsg("保存成功", 1);
                        onReturn();
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

        function onReturn() {
            window.location.href = "./SubPlanControl.aspx";
        }

        function GetUpdatedListJson() {
            var tmpList = [];
            var itemRows = $('#gridTable').getRowData();
            for (i in itemRows) {
                if (  isNaN(parseFloat(itemRows[i].LeftQty))
                    ||isNaN(parseFloat(itemRows[i].RequireQty))  ) {
                    dialogMsg("发现了非数字数据类型, 请核对!", -1);
                    tmpList.length = 0;
                    break;
                }

                tmpList.push({
                    "InturnNumber": itemRows[i].InturnNumber,
                    "ProcessCode": itemRows[i].ProcessCode,
                    "ItemNumber":itemRows[i].ItemNumber,
                    "ItemDsca":itemRows[i].ItemDsca,
                    "UOM":itemRows[i].UOM,
                    "LeftQty": parseFloat(itemRows[i].LeftQty),
                    "RequireQty": parseFloat(itemRows[i].RequireQty)
                });
            }
            return tmpList;
        }

        function request(name) {
            var reg = new RegExp("(^|&)" + name + "=([^&]*)(&|$)");
            var r = window.location.search.substr(1).match(reg);
            if (r != null) return unescape(r[2]); return null;
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
                                    <th><i class="fa fa-bar-chart fa-lg" style="padding-right: 5px;"></i><strong style="font-size:20px">创建下线补单</strong></th>
                                    <td></td>
                                </tr>
                            </table>
                        </div>
                        <div class="panel-body" style="text-align:left">
                            <table class="form" id="ruleinfo" style="margin-top:0px;"  border="0">
                                <tr>
                                    <th class="formTitle">订单编号:</th>
                                    <td class="formValue">
                                        <input type="text" class="form-control" id="WorkOrderNumber" disabled/>
                                    </td>
                                    <th class="formTitle">产品物料编码:</th>
                                    <td class="formValue">
                                        <input type="text" class="form-control" id="GoodsCode" disabled/>
                                    </td>
                                    <td rowspan="2" class="formValue" style="text-align:right; vertical-align:bottom">                                           
                                        <a id="btn_Confirm" class="btn btn-primary"><i class="fa fa-check"></i>确认</a>
                                        <a id="btn_Return"  class="btn btn-primary"><i class="fa fa-reply"></i>返回</a>
                                    </td>
                                </tr>
                                <tr>
                                    <th class="formTitle">订单类型:</th>
                                    <td class="formValue">
                                        <input type="text" class="form-control" id="WorkOrderType" disabled/>
                                    </td>
                                    <th class="formTitle">订单数量:</th>
                                    <td class="formValue">
                                        <input type="text" class="form-control" id="PlanQty" disabled/>
                                    </td>
                                </tr>
                            </table>
                        </div>
                        <div class="rows" style="margin-top:0.5%; width:100%; overflow: hidden; ">
                            <table border="0" style="margin-left:5px;width:100%">
                                <tr>
                                    <th class="formTitle">额外计件物料需求:</th>
                                </tr>
                            </table>
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
        .editable {
               font-size:15px!important;
                font-weight:normal; 
                line-height:1.1;
                text-align:center;      
        }

        @media screen and (max-width: 1400px) { 
           .formTitle {
               font-size:15px;
               width:120px;
           } 

           .form-control {
               font-size:15px;
               width:180px;
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
              width:160px;
          } 
          .form-control {
               font-size:20px;
               width:250px;
               height:40px;
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
