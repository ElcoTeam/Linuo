<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="MaterialBkfReport.aspx.cs" Inherits="LiNuoMes.Mfg.MaterialBkfReport" %>

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

   <%-- <link href="../Content/adminLTE/css/index.css" rel="stylesheet" />--%>
    <link href="../Content/scripts/plugins/jqgrid/jqgrid.css" rel="stylesheet" />
    <link rel="Shortcut icon" href="../images/favicon.ico" />
    <link href="../Content/styles/learun-ui.css" rel="stylesheet" />
    <link href="../css/my.css" rel="stylesheet" media="screen">
    <%--<link href="../Content/scripts/plugins/printTable/learun-report.css" rel="stylesheet" />--%>
    <link href="../Content/styles/learun-report.css" rel="stylesheet" />
    <script src="../Content/scripts/plugins/dialog/dialog.js"></script>
  <%--  <script src="../Content/adminLTE/index.js"></script>--%>
    <script src="../Content/scripts/plugins/jqgrid/grid.locale-cn.js"></script>
    <script src="../Content/scripts/plugins/jqgrid/jqgrid.min.js"></script>
    <script src="../Content/scripts/utils/learun-ui.js"></script>
    <script src="../Content/scripts/utils/learun-form.js"></script>
    <script src="../My97DatePicker/WdatePicker.js"></script>
    <script src="../Content/scripts/plugins/printTable/jquery.printTable.js"></script>
    <script src="ExportGridToExcel.js"></script>
    <script>
        $(function () {
            var user = '<%=Session["UserName"] %>';
            $("#EditPerson").text(user);

            $("#PullTimeStart").val(request('PullTimeStart'));
            $("#PullTimeEnd").val(request('PullTimeEnd'));

            if ($('#areascontent').height() > $(window).height() - 20) {
                $('#areascontent').css("margin-right", "0px");
            }
            $('#areascontent').height($(window).height());
            var areaheight = $("#areascontent").height();
            $(window).resize(function (e) {
                window.setTimeout(function () {
                    $('#gridTable').setGridWidth(($('.gridPanel').width()));
                    $('#gridTable1').setGridWidth(($('.gridPanel').width()));
                    $('#areascontent').height($(window).height() );
                }, 200);
            });
            InitPage();
            fndate();
        });

        //加载表格
        function InitPage() {
            var selectedRowIndex = 0;
            var $gridTable = $('#gridTable');
            //var panelwidth = $('.gridPanel').width();
            $gridTable.jqGrid({
                url: "GetMaterialBkfInfo.ashx",
                postData: {
                    Action: "MaterialBfkReport",
                    PullTimeStart: $("#PullTimeStart").val(),
                    PullTimeEnd: $("#PullTimeEnd").val()
                },
                loadonce: true,
                datatype: "json",
                height: $('#areascontent').height() -300,
                colModel: [
                      { label: '序号', name: 'InturnNumber', hidden: true},
                      { label: '项目', name: 'ID', index: 'ID', width: 50, align: 'left', sortable: false },
                      { label: '物料编码', name: 'ItemNumber', index: 'ItemNumber', width: 100, align: 'left', sortable: false },
                      { label: '物料描述', name: 'ItemDsca', index: 'ItemDsca', width: 250, align: 'left' },
                      { label: '计划领用数', name: 'ApplyQty', index: 'ApplyQty', width: 100, align: 'left' },
                      { label: '实际领用数', name: 'ConfirmQty', index: 'ConfirmQty', width: 100, align: 'left' },
                      { label: '单位', name: 'UOM', index: 'UOM', width: 100, align: 'left', sortable: false },
                      { label: '备注', name: 'Remark', index: 'Remark', width: 300, align: 'left', sortable: false },
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
                    //$("#" + this.id).setSelection(selectedRowIndex, false);

                }
            });

            //查询事件
            $("#btn_Search").click(function () {

                var PullTimeStart = $("#PullTimeStart").val();
                var PullTimeEnd = $("#PullTimeEnd").val();

                $gridTable.jqGrid('setGridParam', {
                    postData: {
                        Action: "MaterialBfkReport",
                        PullTimeStart: PullTimeStart,
                        PullTimeEnd: PullTimeEnd
                    }, page: 1
                }).trigger('reloadGrid');

            });
        }

        //打印
        //function btn_print(event) {
        //    //try {
        //    //    $("#gridPanel").printTable(gridPanel);
        //    //} catch (e) {
        //    //    dialogMsg("Exception thrown: " + e, -1);
        //    //}        
        //    //console.log(newColumnValue);
        //}

        //导出
        function btn_export(event) {
            //var title = $("#title").html();
            var Factory = $("#Factory").text();
            var EditPerson = $("#EditPerson").text();
            var PrintTime = $("#PrintTime").text();
            var PickDept = $("#PickDept").text();
            var Store = $("#Store").text();
            //获取列名  
            var colNames = $('#gridTable').getCol("InturnNumber", false);
            //var newColumnName = [];
            var newColumnValue = [];
            for (var i = 0; i < colNames.length; i++) {
                if (colNames[i] != "") {
                    newColumnValue.push(colNames[i]);
                }
            }

            var materialid = JSON.stringify(newColumnValue);
           
            if (newColumnValue.length > 0)
            {
                ExportJQGridDataToExcel('#gridTable', '反冲材料补货单' + currenttime(), Factory, EditPerson, PrintTime, PickDept, Store, materialid);
                //dialogClose();

                //$.ajax({
                //    url: "MaterialBkfReport.aspx/UpdateExportBkf",
                //    data: JSON.stringify({ arr: newColumnValue }),
                //    type: "post",
                //    async: true,
                //    dataType: "json",
                //    contentType: "application/json;charset=utf-8",
                //    success: function (data) {
                //        if (data.d == "success") {
                //            Loading(false);
                //            dialogMsg("导出成功", 1);
                //            window.parent.$('#gridTable').trigger("reloadGrid");
                //            //$.currentIframe().$("#gridTable").trigger("reloadGrid");
                //            dialogClose();
                //        }
                //        else if (data.d == "falut") {
                //            dialogMsg("导出失败", -1);
                //        }

                //    },
                //    error: function (XMLHttpRequest, textStatus, errorThrown) {
                //        Loading(false);
                //        dialogMsg(errorThrown, -1);
                //    },

                //    complete: function () {
                //        //$("#gridTable").trigger("reloadGrid");
                //        Loading(false);
                //    }
                //});
            }
            
            else
            {
                dialogMsg("当前无数据",0);
            }
           
        }

        var currenttime = function () {
            var date = new Date();
            var seperator1 = "-";

            var month = date.getMonth() + 1;
            var strDate = date.getDate();
            if (month >= 1 && month <= 9) {
                month = "0" + month;
            }
            if (strDate >= 0 && strDate <= 9) {
                strDate = "0" + strDate;
            }

            var currentdate = date.getFullYear().toString() + month.toString() + strDate.toString() 
                        + date.getHours().toString() + date.getMinutes().toString()+ date.getSeconds().toString();
            return currentdate;
        }
        //设置默认时间选择
        function fndate() {
            var xhr = null;
            if (window.XMLHttpRequest) {
                xhr = new window.XMLHttpRequest();
            } else { // ie
                xhr = new ActiveObject("Microsoft")
            }
            // 通过get的方式请求当前文件
            xhr.open("get", "/");
            xhr.send(null);
            // 监听请求状态变化
            xhr.onreadystatechange = function () {
                var time = null,
                    curDate = null;
                if (xhr.readyState === 2) {
                    var seperator1 = "-";
                    // 获取请求头里的时间戳
                    time = xhr.getResponseHeader("Date");
                    //console.log(xhr.getAllResponseHeaders())
                    curDate = new Date(time);
                   
                    //当前时间
                    var month = curDate.getMonth() + 1;
                    var strDate = curDate.getDate();
                    if (month >= 1 && month <= 9) {
                        month = "0" + month;
                    }
                    if (strDate >= 0 && strDate <= 9) {
                        strDate = "0" + strDate;
                    }
                   
                    var currentdate = curDate.getFullYear()
                        + seperator1 + month + seperator1 + strDate + " "
                        + curDate.getHours() + ":" + curDate.getMinutes() + ":" + curDate.getSeconds();
                    
                    $("#PrintTime").text(currentdate);
                   
                }
            }
        }


    </script>
</head>
<body data-spy="scroll" data-target=".navbar-example" id="body1" class="body">

    <!--主体-->
    <div id="areascontent" style="margin:10px 10px 0px 10px; margin-bottom: 0px; overflow: auto;">
         <div class="rows" style="margin-top:0.5%; margin-bottom: 0.8%; overflow: hidden;">
            <div style="float: left; width: 100%;">
                <div style="height:20%; border: 1px solid #e6e6e6; background-color: #fff;">
                    <div class="panel panel-default">
                         <div class="lr-layout-tool">
                            <div class="lr-layout-tool-left">
                            <div class="lr-layout-tool-item">
                            <span class="formTitle">申请时间：</span>
                            <input id="PullTimeStart"  type="text" onFocus="WdatePicker({maxDate:'#F{$dp.$D(\'PullTimeEnd\')}'})" class="Wdate timeselect" />&nbsp;至&nbsp;
                            <input id="PullTimeEnd"  type="text" onFocus="WdatePicker({minDate:'#F{$dp.$D(\'PullTimeStart\')}'})" class="Wdate timeselect" /> 
                            </div>
                            <div class="lr-layout-tool-item" id="multiple_condition_query_item">
                            <div id="multiple_condition_query" class="lr-query-wrap">
                                <div class="lr-query-btn" id="btn_Search" style="font-size:10px;">
                                    <i class="fa fa-search"></i>&nbsp;查询
                                </div>
                            </div>
                            </div>
                            </div>
                            <div class=" lr-layout-tool-right">
                            <div class="btn-group">
                                <a id="lr-export" class="btn btn-default trigger-default" onclick="btn_export(event)"><i class="fa fa-plus"></i>&nbsp;导出</a>
                            </div>
                            </div>
                         </div>
                    </div>
                </div>
            </div>
         </div>
         <div class="rows" style="margin-top:6.5%; overflow: hidden; ">
             
             <div class="gridPanel" id="gridPanel">
             <div class="printArea">
                  <div class="grid-title">
                        <h4 style="text-align:center;">山东力诺瑞特新能源有限公司</h4> 
                        <h4 style="text-align:center;" id="subtitle">反冲材料补货单</h4> 
                   </div>  
                   <div class="grid-subtitle">
                       工厂:     <label id="Factory"  style="width: 450px;" >1111 力若瑞特制造工厂</label>
                       制单人:   <label id="EditPerson"  style="width: 200px;"  ></label>
                       打印时间: <label id="PrintTime"  style="width: 200px;"  ></label>
                   </div>
                   <div class="grid-subtitle">
                       领用库位:     <label id="PickDept"  style="width: 400px;" >平板现场仓 1206</label>
                       发料库位:     <label id="Store"  style="width: 250px;"  >1101  原材料仓</label>
                      
                   </div>
                   <table id="gridTable" style="width:100%;"></table>  
                   <div class="grid-foot" style="text-align: center;">
                       保管员: <label id="KeepPerson"  style="width: 200px;"  ></label> 
                       审核:   <label id="ConfirmPerson"  style="width: 200px;"  ></label>
                       领料员: <label id="PickPerson"  style="width: 400px;"  ></label>
                   </div>      
             </div>
             
         </div>
         </div>


    </div>
     <style>
         .timeselect {
            width: 150px;
            height: 35px;
            font-size: 20px;
         }
    </style>
</body>
</html>








