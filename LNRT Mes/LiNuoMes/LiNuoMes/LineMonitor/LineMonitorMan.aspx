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

    <script src="../js/pdfobject.js" type="text/javascript"></script>
    <script>
        $(function () {
            var id = '<%=Session["UserName"] %>';
            if (id == "")
            {
                location.href = "../Login/Login.aspx";
            }
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
                        optionstring += "<option value=\"" + data1[i].AIO_No + "\" >" + data1[i].Procedure_Name.trim() + "</option>";
                    }
                    $("#currentgw").html(optionstring);
                },
                error: function (msg) {
                    alert("数据访问异常");
                }
            });
           
        }

        function changeline() {

            var value = $("#currentgw").val();

            $.ajax({
                url: "LineMonitorMan.aspx/SetLineInfo",    //后台webservice里的方法名称  
                type: "post",
                dataType: "json",
                data: "{lineno:'"+value+"'}",
                contentType: "application/json;charset=utf-8",
                success: function (data) {
                    var data1 = eval('(' + data.d + ')');
                    var i = 0;//和for循环一样 i做计数
                    for (i in data1) {
                        $("#currentgx").html(data1[i].Procedure_Name);
                        $("#currentperson").html(data1[i].Emp_Name);
                        $("#currentlogintime").html(data1[i].LoginTime);

                        $("#OrderNo").html(data1[i].OrderNo);
                        $("#MaterialCode").html(data1[i].MaterialCode);
                        $("#Order_Qty").html(data1[i].Order_Qty);
                        $("#StartTime").html(data1[i].StartTime);

                        $("#CompletedOrder_Qty").html(data1[i].CompletedOrder_Qty);
                        $("#CompletedStation_Qty").html(data1[i].CompletedStation_Qty);
                        $("#Line_Takt").html(data1[i].Line_Takt);
                        $("#Station_Takt").html(data1[i].Station_Takt);

                        $("#OrderNo_Next").html(data1[i].OrderNo_Next);
                        $("#OrderQty_Next").html(data1[i].OrderQty_Next);
                        $("#MaterialCode_Next").html(data1[i].MaterialCode_Next);
                        $("#Planned_StartTime").html(data1[i].Planned_StartTime);

                        $("#CountDown").html(data1[i].CountDown);
                        PDFObject.embed(data1[i].WI_Path, "#example1", options);

                    }
                },
                error: function (msg) {
                    alert("数据访问异常");
                }
            });
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
                                         <select class="form-control" id="currentgw" style="width:200px;padding:0px;height:45px;" onchange="changeline()">
                                         </select>
                                    </td>
                                    <th class="formTitle">操作人员：</th>
                                    <td class="formValue">
                                        <label id="currentperson" class="form-control" style="border: 0px;">田宇旺</label>
                                    </td>
                                </tr>
                                <tr>
                                    <th class="formTitle">登录时间：</th>
                                    <td class="formValue">
                                        <label id="currentlogintime" class="form-control" style="border: 0px;">08:20:00</label>
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
                                       <label id="OrderNo" class="form-control" style="border: 0px;">20075000</label>
                                   </td>                                  
                               </tr>
                               <tr>
                                   <th class="formTitle">物料编号：</th>
                                   <td class="formValue">
                                       <label id="MaterialCode" class="form-control" style="border: 0px;">3030100000</label>
                                   </td>
                               </tr>
                               <tr>
                                   <th class="formTitle">订单数量：</th>
                                   <td class="formValue">
                                       <label id="Order_Qty" class="form-control" style=" border: 0px;">100</label>
                                   </td>
                                   <th class="formTitle">开始时间：</th>
                                   <td class="formValue">
                                       <label id="StartTime" class="form-control" style="border: 0px;">08:30:00</label>
                                   </td>
                               </tr>
                               <tr>
                                   <th class="formTitle">订单完成数量：</th>
                                   <td class="formValue">
                                       <label id="CompletedOrder_Qty" class="form-control" style="border: 0px;">20</label>
                                   </td>
                                   <th class="formTitle">本工位完成数量：</th>
                                   <td class="formValue">
                                       <label id="CompletedStation_Qty" class="form-control" style="border: 0px;">30</label>
                                   </td>
                               </tr>
                               <tr>
                                   <th class="formTitle">产线生产节拍：</th>
                                   <td class="formValue">
                                       <label id="Line_Takt" class="form-control" style="border: 0px;">120</label>
                                   </td>
                                   <th class="formTitle">本工位生产节拍：</th>
                                   <td class="formValue">
                                       <label id="Station_Takt" class="form-control" style="border: 0px;">40</label>
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
                                        <label id="OrderNo_Next" class="form-control" style="border: 0px;">20075002</label>
                                    </td>
                                </tr>
                                <tr>
                                    <th class="formTitle">物料编码：</th>
                                    <td class="formValue">
                                        <label id="MaterialCode_Next" class="form-control" style="border: 0px;">2610300176</label>
                                    </td>                                   
                                </tr>
                                <tr>
                                    <th class="formTitle">订单数量：</th>
                                    <td class="formValue">
                                        <label id="OrderQty_Next" class="form-control" style="border: 0px;">100</label>
                                    </td>
                                    <th class="formTitle">计划开始时间：</th>
                                    <td class="formValue">
                                        <label id="Planned_StartTime" class="form-control" style="border: 0px;">11:30:00</label>
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
