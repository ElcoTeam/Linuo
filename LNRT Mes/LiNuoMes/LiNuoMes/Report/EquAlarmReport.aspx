<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="EquAlarmReport.aspx.cs" Inherits="LiNuoMes.Report.EquAlarmReport" %>

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
    <link href="../Content/scripts/plugins/printTable/learun-report.css" rel="stylesheet" />
    <script src="../Content/scripts/plugins/dialog/dialog.js"></script>
    <script src="../Content/adminLTE/index.js"></script>
    <script src="../Content/scripts/plugins/jqgrid/grid.locale-cn.js"></script>
    <script src="../Content/scripts/plugins/jqgrid/jqgrid.min.js"></script>
    <script src="../Content/scripts/utils/learun-ui.js"></script>
    <script src="../Content/scripts/utils/learun-form.js"></script>
    <script src="../My97DatePicker/WdatePicker.js"></script>
    <script src="../Content/scripts/plugins/printTable/jquery.printTable.js"></script>
    <script src="ExportGridToExcel.js"></script>
    <script src="../js/highchart.js" type="text/javascript"></script>

    <script>
        var processName = '';
        var deviceName = '';
        var DealWithResult = '';
        var AlarmStartTime = '';
        var AlarmEndTime = '';
        var DealWithStartTime = '';
        var DealWithEndTime = '';
        var AlarmItem = '';

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
            GetGrid();
            CreateSelect();
            GetChart();
            fnDate();
        });

        //加载表格
        function GetGrid() {
            var selectedRowIndex = 0;
            var $gridTable = $('#gridTable');
            $gridTable.jqGrid({
                url: "GetReportInfo.ashx",
                postData: { Action: "EquAlarmReport" },
                loadonce: true,
                datatype: "json",
                height: $('#areascontent').height() *0.4,
                colModel: [
                    { label: '主键', name: 'ID', hidden: true },
                    { label: '序号', name: 'Number', index: 'Number', width: 50, align: 'center' },
                    {
                      label: '工序名称', name: 'ProcessName', index: 'ProcessName', width: 200, align: 'left'
                    },
                    { label: '设备名称', name: 'DeviceName', index: 'DeviceName', width: 200, align: 'left' },
                    { label: '报警时间', name: 'AlarmTime', index: 'AlarmTime', width: 250, align: 'left' },
                    { label: '报警项', name: 'AlarmItem', index: 'AlarmItem', width: 300, align: 'left' },
                    {
                      label: '处理情况', name: 'DealWithResult', index: 'DealWithResult', width: 100, align: 'left'
                    },
                    { label: '处理完成时间', name: 'DealWithTime', index: 'DealWithTime', width: 150, align: 'left' },
                    { label: '处理人', name: 'DealWithOper', index: 'DealWithOper', width: 100, align: 'left' },
                    { label: '处理说明', name: 'DealWithComment', index: 'DealWithComment', width: 100, align: 'left' },
                    { label: '停机时间', name: 'StopTime', index: 'StopTime', width: 100, align: 'center' },
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


           
            //查询事件
            $("#btn_Search").click(function () {
                processName = $("#ProcessName").val();
                deviceName = $("#DeviceName").val();
                DealWithResult = $("#DealWithResult").val();
                AlarmStartTime = $("#AlarmStartTime").val();
                AlarmEndTime = $("#AlarmEndTime").val();
                DealWithStartTime = $("#DealWithStartTime").val();
                DealWithEndTime = $("#DealWithEndTime").val();
                AlarmItem = $("#AlarmItem").val();
                $gridTable.jqGrid('setGridParam', {
                    datatype: 'json',
                    postData: {
                        Action: "EquAlarmReport",
                        ProcessName: processName,
                        DeviceName: deviceName,
                        DealWithResult: DealWithResult,
                        AlarmStartTime: AlarmStartTime,
                        AlarmEndTime: AlarmEndTime,
                        DealWithStartTime: DealWithStartTime,
                        DealWithEndTime: DealWithEndTime,
                        AlarmItem: AlarmItem
                    }
                }).trigger('reloadGrid');

                GetChart();
            });

        }


        function GetChart() {
            processName = $("#ProcessName").val();
            deviceName = $("#DeviceName").val();
            DealWithResult = $("#DealWithResult").val();
            AlarmStartTime = $("#AlarmStartTime").val();
            AlarmEndTime = $("#AlarmEndTime").val();
            DealWithStartTime = $("#DealWithStartTime").val();
            DealWithEndTime = $("#DealWithEndTime").val();
            AlarmItem = $("#AlarmItem").val();
            //柱状图数据
            $.ajax({
                url: "GetReportInfo.ashx",
                data: {
                    Action: "EquAlarmChart",
                    ProcessName: processName,
                    DeviceName: deviceName,
                    DealWithResult: DealWithResult,
                    AlarmStartTime: AlarmStartTime,
                    AlarmEndTime: AlarmEndTime,
                    DealWithStartTime: DealWithStartTime,
                    DealWithEndTime: DealWithEndTime,
                    AlarmItem: AlarmItem
                },
                type: "post",
                datatype: "json",
                success: function (data) {
                    paint(JSON.parse(data));
                },
                error: function (msg) {
                    dialogMsg("数据访问异常", -1);
                }
            });

        }

        //构造select
        function CreateSelect() {
            $("#ProcessName").empty();
            var optionstring = "";
            $.ajax({
                url: "../Equipment/EquDeviceInfo.aspx/GetProcessInfo",
                type: "post",
                dataType: "json",
                data: "{deviceid:''}",
                contentType: "application/json;charset=utf-8",
                success: function (data) {
                    var data1 = eval('(' + data.d + ')');
                    var i = 0;
                    for (i in data1) {
                        optionstring += "<option value=\"" + data1[i].ProcessName + "\" >" + data1[i].ProcessName.trim() + "</option>";
                    }
                    $("#ProcessName").html("<option value=''>请选择...</option> " + optionstring);  
                },
                error: function (msg) {
                    dialogMsg("数据访问异常", -1);
                }
            });           
        }


        function paint(serice) {
            //var datavalue = JSON.parse(serice).datavalue;
            processName = $("#ProcessName").val();
            deviceName = $("#DeviceName").val();
            DealWithResult = $("#DealWithResult").val();
            AlarmStartTime = $("#AlarmStartTime").val();
            AlarmEndTime = $("#AlarmEndTime").val();
            DealWithStartTime = $("#DealWithStartTime").val();
            DealWithEndTime = $("#DealWithEndTime").val();
            AlarmItem = $("#AlarmItem").val();
            var charts = new Highcharts.chart('container', {
                chart: {
                    type: 'column'
                },
                title: {
                    text: '设备故障报警统计图'
                },

                credits: {
                    enabled: false
                },
                //subtitle: {
                //    text: 'Source: WorldClimate.com'
                //},
                xAxis: {
                    categories: []
                },
                yAxis: {
                    title: {
                        text: '报警次数'
                    },
                    labels: {
                        formatter: function () {
                            return this.value;
                        }
                    }
                },
                tooltip: {
                    headerFormat: '<span style="font-size:10px">{point.key}</span><table>',
                    pointFormat: '<tr><td style="color:{series.color};padding:0">{series.name}: </td>' +
                    '<td style="padding:0"><b>{point.y} </b></td></tr>',
                    footerFormat: '</table>',
                    shared: true,
                    useHTML: true
                },
                plotOptions: {
                    column: {
                        borderWidth: 0,
                        cursor: 'pointer',
                        point: {
                            events: {
                                click: function (e) {
                                    //★添加跳转代码★
                                    //alert(e.point.category);
                                    dialogOpen({
                                        id: "Form",
                                        title: '设备保养明细表' + e.point.category,
                                        url: '../Report/EquAlarmDetail.aspx?equid=' + e.point.category + "\
                                        &ProcessName=" + processName + "\
                                        &DeviceName=" + deviceName + "\
                                        &DealWithResult=" + DealWithResult + "\
                                        &AlarmStartTime=" + AlarmStartTime + "\
                                        &AlarmEndTime=" + AlarmEndTime + "\
                                        &DealWithStartTime=" + DealWithStartTime + "\
                                        &DealWithEndTime=" + DealWithEndTime + "\
                                        &AlarmItem" + AlarmItem,
                                        width: "750px",
                                        height: "500px",
                                        btn: null
                                    });
                                }
                            }
                        }
                    }
                },
                series: [{
                    name: '报警次数',
                    data: serice.datavalue
                }]
            });
            //charts.series[0].data=JSON.parse(serice).datavalue;
            charts.xAxis[0].setCategories(serice.catagory);

        }

        //打印
        function btn_print(event) {
            try {
                $("#gridPanel").printTable(gridPanel);
            } catch (e) {
                dialogMsg("Exception thrown: " + e, -1);
            }
        }

        //导出
        function btn_export(event) {
            ExportJQGridDataToExcel('#gridTable', '设备故障报警报表');
        }

        //设置默认时间选择
        function fnDate() {
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
                    var oneweekdate = new Date(curDate.getTime() - 7 * 24 * 3600 * 1000);
                    //当前时间
                    var month = curDate.getMonth() + 1;
                    var strDate = curDate.getDate();
                    if (month >= 1 && month <= 9) {
                        month = "0" + month;
                    }
                    if (strDate >= 0 && strDate <= 9) {
                        strDate = "0" + strDate;
                    }
                    var currentdate = curDate.getFullYear() + seperator1 + month + seperator1 + strDate;
                    //一周前时间
                    var month = oneweekdate.getMonth() + 1;
                    var strDate = oneweekdate.getDate();
                    if (month >= 1 && month <= 9) {
                        month = "0" + month;
                    }
                    if (strDate >= 0 && strDate <= 9) {
                        strDate = "0" + strDate;
                    }
                    var oneweekagodate = oneweekdate.getFullYear() + seperator1 + month + seperator1 + strDate;
                    $("#AlarmEndTime").val(currentdate);
                    $("#AlarmStartTime").val(oneweekagodate);
                }
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
                        <div class="panel-heading"><i class="fa fa-bar-chart fa-lg" style="padding-right: 5px;"></i><strong style="font-size:20px;">设备报警管理</strong></div>
                        <div class="panel-body">
                            <table id="form1" class="form">
                                <tr>
                                    <th class="formTitle">工序名称：</th>
                                    <td class="formValue">
                                       <select class="form-control" id="ProcessName">
                                       </select>
                                    </td>
                                    <th class="formTitle">设备名称：</th>
                                    <td class="formValue">
                                        <input type="text" class="form-control" id="DeviceName" placeholder="请输入设备名称">
                                    </td>
                                    <th class="formTitle">报警时间：</th>
                                    <td class="formValue" colspan="2">
                                          <input id="AlarmStartTime"  type="text" onFocus="WdatePicker({maxDate:'#F{$dp.$D(\'AlarmEndTime\')}'})" class="Wdate timeselect"  readonly/>&nbsp;至&nbsp;
                                          <input id="AlarmEndTime"  type="text" onFocus="WdatePicker({minDate:'#F{$dp.$D(\'AlarmStartTime\')}'})" class="Wdate timeselect"  readonly /> 
                                    </td>
                                                              
                                </tr>
                                <tr>
                                    <th class="formTitle">处理情况：</th>
                                    <td class="formValue">
                                       <select class="form-control" id="DealWithResult">
                                           <option value=''>请选择...</option>
                                           <option value='R'>已处理</option>
                                           <option value='N'>未处理</option>
                                       </select>
                                    </td>   
                                    <th class="formTitle">报警项：</th>
                                    <td class="formValue">
                                        <select class="form-control" id="AlarmItem">
                                           <option value=''>请选择...</option>
                                           <option value='报警'>报警</option>
                                           <option value='物料拉动'>物料拉动</option>
                                       </select>   
                                    </td>     
                                    <th class="formTitle">处理完成时间：</th>
                                    <td class="formValue" colspan="2">
                                          <input id="DealWithStartTime"  type="text" onFocus="WdatePicker({maxDate:'#F{$dp.$D(\'DealWithEndTime\')}'})" class="Wdate timeselect" readonly />&nbsp;至&nbsp;
                                          <input id="DealWithEndTime"  type="text" onFocus="WdatePicker({minDate:'#F{$dp.$D(\'DealWithStartTime\')}'})" class="Wdate timeselect" readonly /> 
                                    </td> 
                                    <td class="formValue">
                                        <a id="btn_Search" class="btn btn-primary"><i class="fa fa-search"></i>&nbsp;查询</a>                        
                                    </td> 
                                </tr>
                                
                            </table>
                        </div>
                    </div>
                </div>
            </div>
        </div>

         <div class="titlePanel">
        <div class="toolbar">
            <div class="btn-group">
                <a id="lr-print" class="btn btn-default" onclick="btn_print(event)"><i class="fa fa-print"></i>&nbsp;打印</a>
                <a id="lr-export" class="btn btn-default trigger-default" onclick="btn_export(event)"><i class="fa fa-plus"></i>&nbsp;导出</a>
            </div>
         </div>
         </div>
         <div class="ui-report" style="margin-top:0.5%; overflow: hidden; ">
              <div class="gridPanel" id="gridPanel">
                  <div class="printArea">
                      <table id="gridTable"></table>                      
                  </div>
              </div>
         </div>
         <div class="center-Panel">
               <div class="panel-Title">统计信息折线图</div>
               <div id="container" style="width: 100%; height: 400px; text-align:center;  margin: 0 auto">
          
               </div>
         </div>
    </div>
    <style>
      .timeselect{
          width: 200px;
      }
      .formTitle{
          width: 200px;
      }
      .form-control{
          width: 250px;
      }
   </style> 
</body>
</html>





