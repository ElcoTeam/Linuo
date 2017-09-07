<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ReportOrderComplete.aspx.cs" Inherits="LiNuoMes.Mfg.ReportOrderComplete" %>

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
                $('#areascontent').css("margin-right", "5px");
             }
             $('#areascontent').height($(window).height()-106);
             var areaheight = $("#areascontent").height();
             $(window).resize(function (e) {
                 window.setTimeout(function () {
                     $('#areascontent').height($(window).height()-106);
                     $('#gridTable').setGridWidth(($('.gridPanel').width()));
                 }, 200);
             });
             
             $(document).delegate(".editable", "focus", function () {
             //    $(this).select();
             });
             
             $(document).delegate(".editable", "blur", function () {
             //    $("#gridTable").saveRow(selectedRowIndex);
             });
             
             InitPage();

             $("#btn_Return").click(function () {
                 window.location.href = "./PlanControl.aspx";
             });

        });

        //加载表格
         function InitPage() {
            var strBtnStyle = "cursor:pointer;margin-left:5px;font-weight:700;padding:.2em .6em .3em;font-size:14px;";
            var $gridTable = $('#gridTable');
            $gridTable.jqGrid({
                url: "GetSetMfg.ashx",
                postData: { Action: "MFG_WO_LIST_ROC" },
                datatype: "json",
                height: $('#areascontent').height() - 180,
                width: $('#areascontent').width,
                rowNum: -1,
                jsonReader: {
                    repeatitems: false,
                    id: "ID"
                },
                colModel: [
                    { label: 'ID', name: 'ID', hidden: true },
                    { label: 'EnableROC', name: 'EnableROC', hidden: true, sortable: false },
                    { label: '序号', name: 'InturnNumber', index: 'InturnNumber', width: 50, align: 'center', sortable: false },
                    { label: '订单编号', name: 'WorkOrderNumber', index: 'WorkOrderNumber', width: 120, align: 'center', sortable: false },
                    { label: '产品物料编码', name: 'GoodsCode', index: 'GoodsCode', width: 160, align: 'center', sortable: false },
                    { label: '产品物料描述', name: 'GoodsDsca', index: 'GoodsDsca', width: 350, align: 'center', sortable: false },
                    {
                        label: '订单类型', name: 'WorkOrderType', index: 'WorkOrderType', width: 100, align: 'center', sortable: false,
                        formatter: function (cellvalue, options, rowObject) {
                            return  cellvalue == "0" ? "正常订单"
                                  : cellvalue == "1" ? "下线补单"
                                  : "";
                        }
                    },
                    { label: '排程日期', name: 'PlanStartTime', index: 'PlanStartTime', width: 140, align: 'center', sortable: false },
                    { label: '订单数量', name: 'PlanQty', index: 'PlanQty', width: 100, align: 'center', sortable: false },
                    { label: '完成数量', name: 'FinishQty', index: 'FinishQty', width: 100, align: 'center', sortable: false },
                    { label: '已报工数量', name: 'Mes2ErpCfmQty', index: 'Mes2ErpCfmQty', width: 100, align: 'center', sortable: false },
                    {
                        label: '待报工数量', name: 'ROCQty', index: 'ROCQty', width: 100, align: 'center', sortable: false,
                        editable: true,
                        editrules: {
                            number: true,
                            custom: false,
                            required: true,
                            minValue: 1,
                            maxValue: 50000
                        }
                    },
                    {
                        label: '操 作', name: 'opcell', index: 'opcell', width: 300, align: 'center', sortable: false,
                        formatter: function (cellvalue, options, rowObject) {
                            var msg;
                            if (rowObject.EnableROC == 'DOROC') {
                                msg = '<button onclick=\"onBtnOk(  \'' + rowObject.ID + '\')\" class=\"btn btn-success\"  style=\"' + strBtnStyle + '"><i class="fa fa-exchange" ></i>报工</button>';
                            }
                            else if (rowObject.EnableROC == 'REDO') {
                                msg = rowObject.ROCMsg;
                                msg += '<button onclick=\"showdlg(   \'' + rowObject.WorkOrderNumber + '\')\" class=\"btn btn-info\"     style=\"' + strBtnStyle + '"><i class="fa fa-list-ul" ></i>查看原因</button>';
                                msg += '<button onclick=\"onBtnRedo( \'' + rowObject.ID              + '\')\" class=\"btn btn-primary\"  style=\"' + strBtnStyle + '"><i class="fa fa-retweet" ></i>重试一次</button>';
                            }
                            else {
                                msg = rowObject.ROCMsg;
                            }
                            return msg;
                        }
                    },
                ],
                shrinkToFit: true,
                autowidth: true,
                scrollrows: true,
                gridview: true,
                onSelectRow: function (rowid){},
                beforeSelectRow: function (rowid) {
                //  if (rowid && rowid != selectedRowIndex) {
                //      if ($("#gridTable").getRowData(selectedRowIndex).EnableROC == 'DOROC') {
                //  //        $("#gridTable").saveRow(selectedRowIndex);
                //      }
                //  }
                //  if ($("#gridTable").getRowData(rowid).EnableROC == 'DOROC') {
                //  //    $("#gridTable").editRow(rowid, true);
                //  }
                    selectedRowIndex = rowid;
                    return false;
                },
                gridComplete: function () {
                    var ids = $("#gridTable").jqGrid().getDataIDs();
                    for (var i = ids.length - 1; i >= 0 ; i--) {
                        var rowData = $("#gridTable").getRowData(ids[i]);
                        if (rowData.EnableROC == 'DOROC') {
                            $("#gridTable").editRow(ids[i], true);
                        }
                    }
                //    $("#gridTable").setSelection(selectedRowIndex, true);
                }
            });

            //查询事件
            $("#btn_Search").click(function () {
                var WorkOrderNumber = $("#WorkOrderNumber").val();
                var PlanDate        = $("#PlanDate").val();
                $gridTable.jqGrid('setGridParam', {
                    postData: {
                        "WorkOrderNumber": WorkOrderNumber,
                        "PlanDate": PlanDate
                    }
                }).trigger('reloadGrid');
            });

            $(":text").keydown(function (event) {
                var keycode = (event.keyCode ? event.keyCode : event.which);
                if (keycode == 13) {
                    $("#btn_Search").trigger("click");
                }
            });
        }

        function onBtnOk(id) {
            selectedRowIndex = id;
            $("#gridTable").saveRow(selectedRowIndex, true);
            var rowData = $('#gridTable').jqGrid('getRowData', selectedRowIndex);
            var ROCID         = rowData.ID;
            var ROCQty        = rowData.ROCQty    ;
            var FinishQty     = rowData.FinishQty ;
            var Mes2ErpCfmQty = rowData.Mes2ErpCfmQty;

            //一定要在此处把选中的行给置编辑态, 否则会产生报错后无法继续现象. 
            //如果提前放到saveRow之后立即进行editRow操作, 则会发生读取数据错误:
            //(尽管数据貌似已经读入到rowData变量中--其实是引用调用造成).
            $("#gridTable").editRow(selectedRowIndex, true);

            if( isNaN( ROCQty) ){
                dialogMsg("请输入有效的数字型数据!", -1);
                return;
            }

            if ( parseInt(ROCQty) > parseInt(FinishQty) - parseInt(Mes2ErpCfmQty) ) {
                dialogMsg("您录入的报工数量已经超出了待报工数量!" ,-1);
                return;
            }

            $.ajax({
                url: "GetSetMfg.ashx",
                data: {
                    "Action": "MFG_WO_LIST_ROC_EDIT",
                    "WoId": ROCID,
                    "ROCQty": parseInt(ROCQty)
                },
                async: true,
                type: "post",
                datatype: "json",
                success: function (data) {
                    Loading(false);
                    data = JSON.parse(data);
                    if (data.result == "success") {
                        $('#gridTable').trigger("reloadGrid");
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

        function onBtnRedo(id) {
            selectedRowIndex = id;
            $.ajax({
                url: "GetSetMfg.ashx",
                data: {
                    "Action": "MFG_WO_LIST_ROC_REDO",
                    "WoId": selectedRowIndex,
                },
                async: true,
                type: "post",
                datatype: "json",
                success: function (data) {
                    Loading(false);
                    data = JSON.parse(data);
                    if (data.result == "success") {
                        $('#gridTable').trigger("reloadGrid");
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

        function showdlg(StdCode) {
            if (StdCode == undefined) {
                StdCode = "0";
            }

            var sTitle = "查看错误原因";
            var sUrl = "SapErrorInformation.aspx";
            var sWidth = "1024px";
            var sHeight = "768px";

            dialogOpen({
                id: "Form",
                title: sTitle,
                url: sUrl + "?RFCName=" + "ZMES_ORDER_CONFIRM" + "&StdCode=" + StdCode,
                width: sWidth,
                height: sHeight,
                callBack: function (iframeId) {
                    top.frames[iframeId].AcceptClick();
                }
            });
        }

        Date.prototype.format = function (format) {
            var o = {
                "M+": this.getMonth() + 1, //month
                "d+": this.getDate(),    //day
                "h+": this.getHours(),   //hour
                "m+": this.getMinutes(), //minute
                "s+": this.getSeconds(), //second
                "q+": Math.floor((this.getMonth() + 3) / 3), //quarter
                "S": this.getMilliseconds() //millisecond
            }
            if (/(y+)/.test(format)) {
                format = format.replace(RegExp.$1, (this.getFullYear() + "").substr(4 - RegExp.$1.length));
            }
            for (var k in o) {
                if (new RegExp("(" + k + ")").test(format)) {
                    format = format.replace(RegExp.$1, RegExp.$1.length == 1 ? o[k] : ("00" + o[k]).substr(("" + o[k]).length));
                }
            }
            return format;
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
    <div id="areascontent" style="margin:50px 10px 5px 10px; margin-bottom: 0px; overflow: auto;">
         <div class="rows" style="margin-top:0.5%; margin-bottom: 0.8%; overflow: hidden;">
            <div style="float: left; width: 100%;">
                <div style="height:20%; border: 1px solid #e6e6e6; background-color: #fff;">
                    <div class="panel panel-default">
                        <div class="panel-heading">
                            <table id="panelheading" border="0" style="width:100%">
                                <tr>
                                    <th><i class="fa fa-check fa-lg" style="padding-right: 5px;"></i><strong style="font-size:20px;">报工</strong></th>
                                    <td></td>
                                </tr>
                            </table>
                        </div>
                        <div class="panel-body" style="text-align:left">
                            <table id="form1" class="form" border="0" style="width:100%">
                                <tr>
                                    <th class="formTitle" style="text-align:right">订单编号：</th>
                                    <td class="formValue" >
                                        <input type="text" class="form-control" id="WorkOrderNumber" style="width:220px" placeholder="订单编号">
                                    </td>                                
                                    <td class="formTitle" style="text-align:right;">排程日期：</td>
                                    <td class="formValue" >
                                        <input type="text" onFocus="WdatePicker({dateFmt:'yyyy-MM-dd', readOnly:true, highLineWeekDay:true, isShowClear:true})" class="Wdate timeselect"  style="width:220px" id="PlanDate" placeholder="排程日期">
                                    </td>
                                    <td class="formValue" style="text-align:right">                                           
                                        <a id="btn_Search" class="btn btn-primary"><i class="fa fa-search"></i>&nbsp;查询 / 刷新</a>  
                                        <a id="btn_Return" class="btn btn-primary"><i class="fa fa-reply"></i>返回 生产排程</a>
                                     </td>
                                </tr>
                            </table>
                        </div>
                    </div>
                </div>
            </div>
        </div>

         <div class="rows" style="margin-top:0.5%; overflow: hidden; ">
              <div class="gridPanel">
                   <table id="gridTable"></table>
                   <div id="gridPager"></div>
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
               width:80px;
           } 
           .form-control {
               font-size:15px;
               width:150px;
               height:30px;
           }
           .aa{
               width:10px;
               height:20px;
           }
           #form1{
               margin-left:0px;
           }
       } 
       @media screen and (min-width: 1400px) { 
           .formTitle {
               font-size:15px;
               width:80px;
           } 
           .form-control {
               font-size:15px;
               width:150px;
               height:30px;
           }
           .aa{
               width:10px;
               height:20px;
           }
           #form1{
               margin-left:0px;
           }
       } 
    </style>
    
</body>
</html>
