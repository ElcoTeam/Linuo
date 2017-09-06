<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="LineMonitorMan.aspx.cs" Inherits="LiNuoMes.LineMonitor.LineMonitorMan" %>

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
    

    <script src="../js/pdfobject.js" type="text/javascript"></script>
    <script>
        $(function () {
            var id = '<%=Session["UserName"] %>';
            if (id == "")
            {
                location.href = "../Login/Login.aspx";
            }
            $("#currentperson").text(id);

            if ($(window).height() > 900) {
                $('#areascontent').height($(window).height() -100);
            }
            else {
                $('#areascontent').height($(window).height() + 100);

            }
            var areaheight = $("#areascontent").height();
            $(window).resize(function (e) {
                window.setTimeout(function () {
                    if ($(window).height() > 1000 + 'px') {
                        $('#areascontent').height($(window).height() - 100);
                    }
                    else {
                        $('#areascontent').height($(window).height() + 100);

                    }
                }, 200);
            });
            CreateSelect();
            fnDate();
            
            function count($this) {
                var current = parseInt($this.html(), 10);
                
                $this.html(--current);
                if (current ==0) {
                    $this.html(0);
                } else {
                    setTimeout(function () { count($this) }, 1000);
                }
            }

            jQuery("#CountDown").each(function () {
               
                count(jQuery(this));
            });
        });

        //构造select
        function CreateSelect() {
            $("#currentgw").empty();
            var optionstring = "";
            $.ajax({
                url: "LineMonitorMan.aspx/GetLineInfo",    //后台webservice里的方法名称  
                type: "post",
                dataType: "json",
                data: "{deviceid:''}",
                contentType: "application/json;charset=utf-8",
                success: function (data) {
                    var data1 = eval('(' + data.d + ')');
                    var i = 0;//和for循环一样 i做计数
                    for (i in data1) {
                        optionstring += "<option value=\"" + data1[i].ProcessCode + "\" >" + data1[i].ProcessName.trim() + "</option>";
                    }
                    $("#currentgw").html(optionstring);
                    InitalPage($("#currentgw").val());
                },
                error: function (msg) {
                    alert("数据访问异常");
                }
            });
           
        }

        function changeline() {
            var value = $("#currentgw").val();
            InitalPage(value);
        }

        //当前订单
        function InitalPage(data)
        {
            $.ajax({
                url: "LineMonitorMan.aspx/SetLineInfo",    //后台webservice里的方法名称  
                type: "post",
                dataType: "json",
                data: "{lineno:'" + data + "'}",
                contentType: "application/json;charset=utf-8",
                success: function (data) {
                    if (data.d!='') {
                        var data1 = eval('(' + data.d + ')');
                        var i = 0;
                        for (i in data1) {

                            $("#OrderNo").html(data1[i].WorkOrderNumber);
                            $("#OrderVersion").html(data1[i].MesWorkOrderVersion);
                            $("#MaterialCode").html(data1[i].ErpGoodsCode);
                            $("#MaterialDSCA").html(data1[i].ErpGoodsDsca);
                            $("#Order_Qty").html(data1[i].ErpPlanQty);
                            $("#StartTime").html(data1[i].MesActualStartTime);
                            $("#CompletedOrder_Qty").html(data1[i].MesFinishQty);
                            $("#CompletedStation_Qty").html(data1[i].ProcessFinishNum);
                            $("#Line_Takt").html(data1[i].LineBeat);
                            $("#Station_Takt").html(data1[i].ProcessBeat);
                            $("#CountDown").html(data1[i].ProcessBeat);
                            
                        }
                        IntialNext($("#OrderNo").html(),$("#OrderVersion").html());
                    }
                    else
                    {
                        $("#OrderNo").html("");
                        $("#MaterialCode").html("");
                        $("#MaterialDSCA").html("");
                        $("#Order_Qty").html("");
                        $("#StartTime").html("");

                        $("#CompletedOrder_Qty").html("");
                        $("#CompletedStation_Qty").html("");
                        $("#Line_Takt").html("");
                        $("#Station_Takt").html("");                     
                        $("#CountDown").html("");
                    }
                },
                error: function (msg) {
                    alert("数据访问异常");
                }
            });
        }

        function IntialNext(data,orderversion)
        {
    
            $.ajax({
                url: "LineMonitorMan.aspx/SetNextLineInfo",    //后台webservice里的方法名称  
                type: "post",
                dataType: "json",
                data: "{lineno:'" + data + "',orderversion:'" + orderversion + "'}",
                contentType: "application/json;charset=utf-8",
                success: function (data) {
                    console.log(data);
                    if (data.d!='')
                    {
                        var data1 = eval('(' + data.d + ')');
                        var i = 0;
                        for (i in data1) {
                            $("#OrderNo_Next").html(data1[i].ErpWorkOrderNumber);
                            $("#MaterialCode_Next").html(data1[i].ErpGoodsCode);
                            $("#MaterialDSCA_Next").html(data1[i].ErpGoodsDsca);
                            $("#OrderQty_Next").html(data1[i].ErpPlanQty);
                            $("#Planned_StartTime").html(data1[i].ErpPlanStartTime);
                        }
                    }
                    else
                    {
                        $("#OrderNo_Next").html("");
                        $("#MaterialCode_Next").html("");
                        $("#MaterialDSCA_Next").html("");
                        $("#OrderQty_Next").html("");
                        $("#Planned_StartTime").html("");
                    }
                   
                },
                error: function (msg) {
                    alert("数据访问异常");
                }
            });
        }

        //登陆时间
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
                    var seperator2 = ":";
                    // 获取请求头里的时间戳
                    time = xhr.getResponseHeader("Date");
                    //console.log(xhr.getAllResponseHeaders())
                    curDate = new Date(time);
                    var month = curDate.getMonth() + 1;
                    var strDate = curDate.getDate();
                    if (month >= 1 && month <= 9) {
                        month = "0" + month;
                    }
                    if (strDate >= 0 && strDate <= 9) {
                        strDate = "0" + strDate;
                    }
                    var currentdate = curDate.getFullYear() + seperator1 + month + seperator1 + strDate
                              + " " + curDate.getHours() + seperator2 + curDate.getMinutes()
                              + seperator2 + curDate.getSeconds();
                    
                    $("#currentlogintime").html(currentdate);
                }
            }

        }
    </script>
</head>
<body data-spy="scroll" data-target=".navbar-example" id="body">
    <div id="ajax-loader" style="cursor: progress; position: fixed; top: -50%; left: -50%; width: 200%; height: 200%; background: #fff; z-index: 10000; overflow: hidden;">
        <img src="../Content/images/ajax-loader.gif" style="position: absolute; top: 0; left: 0; right: 0; bottom: 0; margin: auto;" />
    </div>
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
                        <div class="panel-heading"><i class="fa fa-bar-chart fa-lg" style="padding-right: 5px;"></i>工位信息</div>
                        <div class="panel-body">
                            <table class="form">
                                <tr>
                                    <th class="formTitle">所在工序：</th>
                                    <td class="formValue">
                                        <%--<label id="currentgx" class="form-control" style=" border: 0px;">排管焊接</label>--%>
                                         <select class="form-control" id="currentgw" style="padding:0px;height:45px;" onchange="changeline()">
                                         </select>
                                    </td>
                                    <th class="formTitle">操作人员：</th>
                                    <td class="formValue">
                                        <label id="currentperson" class="form-control" style="border: 0px;"></label>
                                    </td>
                                </tr>
                                <tr>
                                    <th class="formTitle">登录时间：</th>
                                    <td class="formValue">
                                        <label id="currentlogintime" class="form-control" style="border: 0px;"></label>
                                    </td>
                                </tr>
                            </table>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <div class="rows" style="margin-top:0.5%; overflow: hidden; height:75%;">
            <div style="float: left; width: 40%; height:100%;">
                <div style="height: 100%; border: 1px solid #e6e6e6; background-color: #fff;">
                    <div class="panel panel-default"  style="height:100%;">
                        <div class="panel-heading"><i class="fa fa-send fa-lg" style="padding-right: 5px;"></i>操作规范</div>
                        <div class="panel-body" id="example1"  style="height:100%;" >                          
			                                   
                        </div>
                    </div>
                </div>
            </div>
       
            <div style="float: right; width: 59%; height:51%;">
                <div style="height:100%; border: 1px solid #e6e6e6; background-color: #fff;">
                  <div class="panel panel-default" style="height:100%;">
                     <div class="panel-heading"><i class="fa fa-thumbs-o-up fa-lg" style="padding-right: 5px;"></i>当前订单</div>
                       <div class="panel-body">
                           <table class="form" style="margin: 0px 0px 0px 0px;">
                               <tr>
                                   <th class="formTitle">订单编号：</th>
                                   <td class="formValue">
                                       <label id="OrderNo" class="form-control" style="border: 0px;"></label>
                                       <label id="OrderVersion" class="form-control" style="border: 0px; display: none" ></label>
                                   </td>   
                                   <th class="formTitle">物料编号：</th>
                                   <td class="formValue">
                                       <label id="MaterialCode" class="form-control" style="border: 0px;"></label>
                                       
                                   </td>                               
                               </tr>
                               <tr>
                                   <th class="formTitle">物料描述：</th>
                                   <td class="formValue" colspan="3">
                                       <label id="MaterialDSCA" class="form-control" style="border: 0px; width:1000px;"></label>
                                   </td> 
                               </tr>
                               <tr>
                                   <th class="formTitle">订单数量：</th>
                                   <td class="formValue">
                                       <label id="Order_Qty" class="form-control" style=" border: 0px;"></label>
                                   </td>
                                   <th class="formTitle">开始时间：</th>
                                   <td class="formValue">
                                       <label id="StartTime" class="form-control" style="border: 0px;"></label>
                                   </td>
                               </tr>
                               <tr>
                                   <th class="formTitle">订单完成数量：</th>
                                   <td class="formValue">
                                       <label id="CompletedOrder_Qty" class="form-control" style="border: 0px;"></label>
                                   </td>
                                   <th class="formTitle">本工位完成数量：</th>
                                   <td class="formValue">
                                       <label id="CompletedStation_Qty" class="form-control" style="border: 0px;"></label>
                                   </td>
                               </tr>
                               <tr>
                                   <th class="formTitle">产线生产节拍：</th>
                                   <td class="formValue">
                                       <label id="Line_Takt" class="form-control" style="border: 0px;"></label>
                                   </td>
                                   <th class="formTitle">本工位生产节拍：</th>
                                   <td class="formValue">
                                       <label id="Station_Takt" class="form-control" style="border: 0px;"></label>
                                   </td>
                               </tr>
                           </table>
                        </div>
                    </div>
                </div>
            </div>

            <div style="margin-top:0.5%; float: right; width: 59%; height:35%;">
                <div style="height: 100%; border: 1px solid #e6e6e6; background-color: #fff;">
                    <div class="panel panel-default">
                        <div class="panel-heading"><i class="fa fa-rss fa-lg" style="padding-right: 5px;"></i>下一订单</div>
                        <div class="panel-body">
                            <table class="form" style="margin: 10px 0px 0px 0px;">
                                <tr>
                                    <th class="formTitle">订单编号：</th>
                                    <td class="formValue">
                                        <label id="OrderNo_Next" class="form-control" style="border: 0px;"></label>
                                    </td>
                                    <th class="formTitle">物料编码：</th>
                                    <td class="formValue">
                                        <label id="MaterialCode_Next" class="form-control" style="border: 0px;"></label>
                                    </td>   
                                </tr>
                                <tr>
                                   <th class="formTitle">物料描述：</th>
                                   <td class="formValue" colspan="3">
                                       <label id="MaterialDSCA_Next" class="form-control" style="border: 0px; width:1000px;"></label>
                                   </td>                                
                                </tr>
                                <tr>
                                    <th class="formTitle">订单数量：</th>
                                    <td class="formValue">
                                        <label id="OrderQty_Next" class="form-control" style="border: 0px;"></label>
                                    </td>
                                    <th class="formTitle">计划开始时间：</th>
                                    <td class="formValue">
                                        <label id="Planned_StartTime" class="form-control" style="border: 0px;"></label>
                                    </td>   
                                </tr>
                            </table>
                        </div>
                    </div>
                </div>
            </div>

            <div style="margin-top:0.5%;float:right;width:59%; height:11.2%;">
                <div style="height:100%; border: 1px solid #e6e6e6; background-color: #fff;">
                    <div class="panel panel-default">
                       
                        <div class="panel-body">
                            <table class="form" style="margin: 10px 0px 0px 0px;">
                                <tr>
                                    <th class="formTitle"></th>
                                    <td class="formValue">
                                        
                                    </td>
                                    <th class="formTitle">节拍倒计时：</th>
                                    <td class="formValue">
                                        <label id="CountDown" class="form-control" style="border: 0px;">80</label>
                                    </td>
                                </tr>
                               
                            </table>
                        </div>
                    </div>
                </div>
            </div>
        </div>
 
    </div>
    <style>
     
          .pdfobject { border: 1px solid #fff; }
        
    </style>
   
    <script>
        var options = {
            pdfOpenParams: {
                pagemode: "none"
                , navpanes: 0
                , toolbar: 0
                , statusbar: 0
                //   ,view:"FitBH"
            }
                , width: "100%"
                , height: "100%"
                , page: "1"
                , fallbackLink: "<p>Please install the PDF Reader First!</p>"
        };

        var myPDF = PDFObject.embed("./img/TPJG.pdf", "#example1", options);

    </script>
</body>
</html>
