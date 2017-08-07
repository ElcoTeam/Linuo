<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="PlcSendMain.aspx.cs" Inherits="LiNuoMes.Mfg.PlcSendMain" %>

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
    <script type="text/javascript" src="../js/m.js" charset="gbk"></script>
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
    <link href="../Content/styles/learun-ui.css?v=xGgPBYcCVZtMx26lXm_bETZOl5nvwnNwIiq-fpPtywo1" rel="stylesheet" />
    <link href="../css/my.css" rel="stylesheet" media="screen">
    <link href="../css/iziModal.css" rel="stylesheet" />
    <script src="../Content/scripts/plugins/dialog/dialog.js"></script>
    <script src="../Content/adminLTE/index.js"></script>
    <script src="../Content/scripts/plugins/jqgrid/grid.locale-cn.js"></script>
    <script src="../Content/scripts/plugins/jqgrid/jqgrid.min.js"></script>
    <script src="../Content/scripts/utils/learun-ui.js"></script>
    <script src="../Content/scripts/utils/learun-form.js"></script>
    <script src="../js/iziModal.min.js"></script>
    <script src="../BaseConfig/GetSetBaseConfig.js"></script>
    <script>
        var selectedRowIndex0 = 0;
        $(function () {
            if ($('#areascontent').height() > $(window).height() - 20) {
                $('#areascontent').css("margin-right", "0px");
            }
            $('#areascontent').height($(window).height() - 106);
            var areaheight = $("#areascontent").height();
            $(window).resize(function (e) {
                window.setTimeout(function () {
                    $('#areascontent').height($(window).height() - 106);
              //      $('#areascontent').width($(window).width() - 20);
                    $('#gridTable0').setGridWidth(($('#areascontent').width()) - 10);
              //      $('#gridTable0').setGridHeight($('#areascontent').height() * 0.60);
                }, 200);
            });

            InitPage0();
        });

        function InitPage0() {
            var strBtnStyle = "cursor:pointer;margin-left:5px;font-weight:700;padding:.2em .6em .3em;font-size:14px;";
            var $gridTable0 = $('#gridTable0');
            $gridTable0.jqGrid({
                url: "./GetSetMfg.ashx",
                postData: { Action: "MFG_WO_LIST" },
                datatype: "json",
                height: $('#areascontent').height() * 0.60,
                width: $('#areascontent').width,
                rowNum: -1,
                jsonReader: {
                    repeatitems: false,   //此两个参数影响了是否刷新之后高亮选中记录: 如果直接设定为true, 则无论id项设定与否都可以实现高亮选中
                    id: "ID"              //此两个参数影响了是否刷新之后高亮选中记录: 需要设定为唯一字段即可,如果设定为0值, 则需要repeatitems为true才可以.
                },
                colModel: [
                    { label: 'ID', name: 'ID', hidden: true },
                    { label: '版本', name: 'WorkOrderVersion', hidden: true, sortable: false },
                    { label: '序号', name: 'InturnNumber', index: 'InturnNumber', width: 80, align: 'center', sortable: false },
                    { label: '订单编号', name: 'WorkOrderNumber', index: 'WorkOrderNumber', width: 140, align: 'center', sortable: false },
                    { label: '产品物料编码', name: 'GoodsCode', index: 'GoodsCode', width: 220, align: 'center', sortable: false },
                    {
                        label: '订单类型', name: 'WorkOrderType', index: 'WorkOrderType', width: 120, align: 'center', sortable: false,
                        formatter: function (cellvalue, options, rowObject) {
                            return cellvalue == "0" ? "正常订单"
                                 : cellvalue == "1" ? "下线补单"
                                 : "";
                        }
                    },
                    { label: '计划开始时间', name: 'PlanStartTime', index: 'PlanStartTime', width: 200, align: 'center', sortable: false },
                    { label: '计划完成时间', name: 'PlanFinishTime', index: 'PlanFinishTime', width: 200, align: 'center', sortable: false },
                    { label: '预计耗时', name: 'CostTime', index: 'CostTime', width: 80, align: 'center', sortable: false },
                    { label: '订单数量', name: 'PlanQty', index: 'PlanQty', width: 80, align: 'center', sortable: false },
                    {
                        label: '上线工序', name: 'StartPoint', index: 'StartPoint', width: 100, align: 'center', sortable: false,
                        formatter: function (cellvalue, options, rowObject) {
                            return cellvalue == "0" ? "首道工序"
                                 : cellvalue == "1" ? "上线点1"
                                 : cellvalue == "2" ? "上线点2"
                                 : cellvalue == "3" ? "上线点3"
                                 : "";
                        }
                    },
                    { label: '订单状态', name: 'Status', index: 'Status', width: 120, align: 'center', sortable: false },
                    {
                        label: '操 作', width: 280, align: 'center', sortable: false,
                        formatter: function (cellvalue, options, rowObject) {
                            var rtstring = 
                              '<button ID=\"SEND_BTN_' + rowObject.ID + '\" onclick=\"onPLCSend( \'' + rowObject.GoodsCode + '\', \'' + rowObject.WorkOrderNumber + '\', \'' + rowObject.WorkOrderVersion + '\')\" class=\"btn btn-success\" style=\"' + strBtnStyle + '\"><i class="fa fa-bars"   ></i>参数派发</button>'
                            + '<button ID=\"CHAN_BTN_' + rowObject.ID + '\" onclick=\"onPLCChan( \'' + rowObject.GoodsCode + '\', \'' + rowObject.WorkOrderNumber + '\', \'' + rowObject.WorkOrderVersion + '\')\" class=\"btn btn-success\" style=\"' + strBtnStyle + '\"><i class="fa fa-bars"   ></i>产品变更</button>';
                            return rtstring;
                        }
                    }
                ],
                shrinkToFit: true,
                autowidth: true,
                scroll: true,
                multiselect: false,
                gridview: true,
                onSelectRow: function (rowid) {
                    selectedRowIndex0 = $("#gridTable0").jqGrid("getGridParam", "selrow");
                },
                gridComplete: function () {
                    $("#gridTable0").setSelection(selectedRowIndex0, true);
                    g_getSetParam("PlayPause", "", "READ", onPausePlay);
                }
            });
        }

        function onPausePlay(data) {
            
            //“已完成”订单的“PLC参数派发”按钮不可用；
            //“生产进行中”或“产前调整中”订单的“PLC参数派发”按钮可用；
            //如存在“产前调整中”的订单，则其之后各订单的“PLC参数派发”按钮均不可用；
            //如不存在“产前调整中”的订单，则第一个“待生产”订单的“PLC参数派发”按钮可用；
            var firstAdjust = true;  //是否第一个产前调整中
            var ids = $('#gridTable0').getDataIDs();

            for (var i = 0; i < ids.length; i++) {
                var row  = $('#gridTable0').getRowData(ids[i]);
                var btn0 = $("#SEND_BTN_" + String(row.ID));
                var btn1 = $("#CHAN_BTN_" + String(row.ID));                
                if (row.Status == "0") {
                    //待生产状态先全部禁用, 等到此处循环结束后统计结果后再做设定第一条订单记录的状态.
                    btn0.attr("disabled", true);
                    btn1.attr("disabled", true);
                }
                else if (row.Status == "1") {
                    if (firstAdjust == true) {
                        //do nothing: in order to ENABLE the first line.
                        firstAdjust = false;
                    }
                    else {
                        btn0.attr("disabled", true);
                        btn1.attr("disabled", true);
                    }
                }
                else if (row.Status == "2") {
                    //do nothing: in order to ENABLE all the playing line.
                }
                else if (row.Status == "3") {
                    btn0.attr("disabled", true);
                    btn1.attr("disabled", true);
                }
            }

            //如果不存在产前调整中状态, 如果有过至少一次, 则初始值就会发生变化.        
            if (firstAdjust == true) {
                for (var i = 0; i < ids.length; i++) {
                    var row  = $('#gridTable0').getRowData(ids[i]);
                    var btn0 = $("#SEND_BTN_" + String(row.ID));
                    var btn1 = $("#CHAN_BTN_" + String(row.ID));
                    if (row.Status == "0") {
                        //MES全局控制参数: 点击“暂停待生产订单”按钮，系统禁止“待生产”状态订单的物料拉动及PLC参数派发
                        //也就是说: 在系统PLAY状态下的第一个待生产订单是可以派发的.
                        if (data == "PLAY") {
                            btn0.removeAttr("disabled");
                            btn1.removeAttr("disabled");
                        }
                        break;
                   }
                }
            }

            for (var i = 0; i < ids.length; i++) {
                var row = $('#gridTable0').getRowData(ids[i]);
                $('#gridTable0').jqGrid("setRowData", ids[i], { Status: StaTip(row.Status) });
            }
        }

        function StaTip(cellvalue)
        {
            var ret =              
                  cellvalue == "0" ? "待生产"
                : cellvalue == "1" ? "产前调整中"
                : cellvalue == "2" ? "生产进行中"
                : cellvalue == "3" ? "已完成"
                : "";
            return ret;
        }

        function onPLCSend(GoodsCode, WorkOrderNumber, WorkOrderVersion) {
            window.location.href = "./PLCSendOperate.aspx?GoodsCode=" + GoodsCode + "&WorkOrderNumber=" + WorkOrderNumber + "&WorkOrderVersion=" + WorkOrderVersion ;
        }

        function onPLCChan(GoodsCode, WorkOrderNumber, WorkOrderVersion) {
            window.location.href = "./PLCChanOperate.aspx?GoodsCode=" + GoodsCode + "&WorkOrderNumber=" + WorkOrderNumber + "&WorkOrderVersion=" + WorkOrderVersion ;
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
                                    <th><i class="fa fa-bar-chart fa-lg" style="padding-right: 5px;"></i><strong style="font-size:20px">当日订单PLC参数派发管理</strong></th>
                                    <td></td>
                                </tr>
                            </table>
                        </div>
                        <div class="panel-body" style="text-align:left">
                            <table class="form" border="0">
                                <tr>
                                    <th class="formTitle" style="width:180px;font-weight:bold;text-align:right">当日生产排程</th>                                    
                                    <td class="formValue" style="text-align:right"></td>
                                </tr>
                            </table>
                        </div>
                        <div class="rows" style="margin-top:0.5%; width:100%; overflow: hidden; ">
                              <div class="gridPanel">
                                   <table id="gridTable0"></table>
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
