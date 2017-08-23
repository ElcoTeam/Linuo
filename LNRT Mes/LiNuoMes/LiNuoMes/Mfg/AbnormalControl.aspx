<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="AbnormalControl.aspx.cs" Inherits="LiNuoMes.Mfg.AbnormalControl" %>

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
    <script src="../My97DatePicker/WdatePicker.js"></script>
    <script src="../js/iziModal.min.js"></script>
    <script>
        var selectedRowIndex = 0;
        $(function () {

            $("#FromTime").val(new Date().DateAdd('d', -7).format('yyyy-MM-dd') + ' 00:00');
            $("#ToTime").val(new Date().DateAdd('d', 1).format('yyyy-MM-dd') + ' 00:00');

            if ($('#areascontent').height() > $(window).height() - 20) {
                $('#areascontent').css("margin-right", "0px");
            }
            $('#areascontent').height($(window).height() - 106);
            var areaheight = $("#areascontent").height();
            $(window).resize(function (e) {
                window.setTimeout(function () {
                    $('#areascontent').height($(window).height() - 106);
                //    $('#areascontent').width($(window).width() - 20);  //此处隐藏的两项不要加入,如果加入会引起死机:原因:貌似引起了递归调用.
                    $('#gridTable').setGridWidth(($('#areascontent').width()) - 10);
                //    $('#gridTable').setGridHeight($('#areascontent').height() - 200);
                }, 200);
            });

            InitPage();
            initAbPointContent();

            $('#AbnormalPoint,#AbnormalType').change(function () {
                 $('#btn_Search').trigger("click");
            });
       
            $(":text").bind("focus",
                function () {
                    $(this).select();
                    $(this).css("font-size:14px;");
                });
       

            $(":text").keydown(function (event) {
                var keycode = (event.keyCode ? event.keyCode : event.which);
                if (keycode == 13) {
                    $("#btn_Search").trigger("click");
                }
            });

            $("#btn_Search").click(function () {
                var RFID = $("#RFID").val();
                var WorkOrderNumber = $("#WorkOrderNumber").val();
                var GoodsCode = $("#GoodsCode").val();
                var AbnormalPoint = $("#AbnormalPoint").val();
                var AbnormalType = $("#AbnormalType").val();
                var FromTime = $("#FromTime").val();
                var ToTime = $("#ToTime").val();

                if (RFID == undefined) {
                    RFID = "";
                }

                RFID = RFID.toUpperCase().trim();
                $("#RFID").val(RFID);

                if (WorkOrderNumber == undefined) {
                    WorkOrderNumber = "";
                }

                WorkOrderNumber = WorkOrderNumber.toUpperCase().trim();
                $("#WorkOrderNumber").val(WorkOrderNumber);

                if (GoodsCode == undefined) {
                    GoodsCode = "";
                }

                GoodsCode = GoodsCode.toUpperCase().trim();
                $("#GoodsCode").val(GoodsCode);

                if (AbnormalPoint == undefined) {
                    AbnormalPoint = "";
                }

                if (AbnormalType == undefined) {
                    AbnormalType = "";
                }

                if (FromTime == undefined) {
                    FromTime = "";
                }

                if (ToTime == undefined) {
                    ToTime = "";
                }

                WorkOrderNumber = WorkOrderNumber.toUpperCase().trim();

                $("#gridTable").jqGrid('setGridParam',
                    {
                        postData: {
                            "WorkOrderNumber": WorkOrderNumber,
                            "RFID": RFID,
                            "GoodsCode": GoodsCode,
                            "AbnormalPoint": AbnormalPoint,
                            "AbnormalType": AbnormalType,
                            "FromTime": FromTime,
                            "ToTime": ToTime
                        }
                    }).trigger('reloadGrid');

            });

            $("#btn_Create").click(function () {
                showdlg("ABN","ADD","0");
            });

        });

        function InitPage() {
            var panelwidth = $('#areascontent').width();
            var strBtnStyle = "cursor:pointer;margin-left:5px;font-weight:700;padding:.2em .6em .3em;font-size:14px;";
            var $gridTable = $('#gridTable');
            $gridTable.jqGrid({
                url: "./GetSetMfg.ashx",
                postData: {
                    "Action": "MFG_WIP_DATA_ABNORMAL",
                    "FromTime": $("#FromTime").val(),
                    "ToTime": $("#ToTime").val()
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
                    { label: 'SubPlanStatus', name: 'SubPlanStatus', hidden: true, sortable: false },
                    { label: '序号', name: 'InturnNumber', index: 'InturnNumber', width: panelwidth * 0.03, align: 'center', sortable: false },
                    { label: '订单编号', name: 'WorkOrderNumber', index: 'WorkOrderNumber', width: panelwidth * 0.08, align: 'center', sortable: false },
                    { label: 'MES码', name: 'RFID', index: 'RFID', width: panelwidth * 0.15, align: 'center', sortable: false },
                    { label: '产品物料编码', name: 'GoodsCode', index: 'GoodsCode', width: panelwidth * 0.14, align: 'center', sortable: false },
                    { label: '下线工序', name: 'AbnormalDisplayValue', index: 'AbnormalDisplayValue', width: panelwidth * 0.09, align: 'center', sortable: false },
                    {
                        label: '下线类型', name: 'AbnormalType', index: 'AbnormalType', width: panelwidth * 0.04, align: 'center', sortable: false,
                        formatter: function (cellvalue, options, rowObject) {
                            return  cellvalue == "0" ? "正常订单"
                                  : cellvalue == "1" ? "补修"
                                  : cellvalue == "2" ? "报废"
                                  : cellvalue == "3" ? "未完工"
                                  : "";
                        }
                    },
                    { label: '下线时间', name: 'AbnormalTime', index: 'AbnormalTime', width: panelwidth * 0.14, align: 'center', sortable: false },
                    { label: '下线人员', name: 'AbnormalUser', index: 'AbnormalUser', width: panelwidth * 0.05, align: 'center', sortable: false },
                    { label: '物料维护', name: 'MaintainCol', width: panelwidth * 0.14, align: 'center', sortable: false },
                    { label: '操 作',   name: 'OperateCol', width: panelwidth * 0.14, align: 'center', sortable: false  },

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
                    var ids = $gridTable.jqGrid('getDataIDs'); //获取表格的所有列
                    for (var i = 0; i < ids.length; i++) {
                        var id = ids[i];
                        var strMaintain = "";
                        var strOperate = "";
                        var strEnable = "";

                        if ( $gridTable.jqGrid('getRowData', id).SubPlanStatus != 0 ){
                            strEnable = "disabled";
                        }
                        strMaintain += '<button                   onclick=\"showdlg(\'MTL\',\'CHECK\', \'' + id + '\')\" class=\"btn btn-success\" style=\"' + strBtnStyle + '\"><i class="fa fa-check-square-o"></i>查看</button>';
                        strMaintain += '<button ' + strEnable + ' onclick=\"showdlg(\'MTL\',\'EDIT\',  \'' + id + '\')\" class=\"btn btn-success\" style=\"' + strBtnStyle + '\"><i class="fa fa-edit"></i>修改</span>';
                        strOperate  += '<button                   onclick=\"showdlg(\'ABN\',\'CHECK\', \'' + id + '\')\" class=\"btn btn-success\" style=\"' + strBtnStyle + '\"><i class="fa fa-check-square-o"></i>查看</button>';
                        strOperate  += '<button ' + strEnable + ' onclick=\"showdlg(\'ABN\',\'EDIT\',  \'' + id + '\')\" class=\"btn btn-success\" style=\"' + strBtnStyle + '\"><i class="fa fa-edit"></i>修改</span>';

                        $gridTable.jqGrid('setRowData', ids[i], { MaintainCol: strMaintain });
                        $gridTable.jqGrid('setRowData', ids[i], { OperateCol: strOperate });
                    }
                }
            });

        }

        //编辑信息
        function showdlg(dlgType, OPtype, AbId) {
            if (AbId == undefined) {
                AbId = $("#gridTable").jqGridRowValue("ID");
            }

            if (OPtype == undefined) {
                OPtype = "CHECK";
            }

            var sTitle = "";
            var sUrl = "";
            var sWidth = "640px";
            var sHeight = "600px"
            
            if(dlgType == 'ABN'){
                if (OPtype == "CHECK") {
                    sTitle = "查看产品下线记录";
                    sUrl = "AbnormalDetailEdit.aspx?";
                }
                else if (OPtype == "EDIT") {
                    sTitle = "修改产品下线记录";
                    sUrl = "AbnormalDetailEdit.aspx?";
                }
                else if (OPtype == "ADD") {
                    sTitle = "新增产品下线记录";
                    sUrl = "AbnormalDetailEdit.aspx?";
                }             
            }
            else if (dlgType == 'MTL') {

                sWidth = "800px";
                sHeight = "600px"

                if (OPtype == "CHECK") {
                    sTitle = "查看下线产品计件物料清单";
                    sUrl = "AbnormalMtlEdit.aspx?";
                }
                else if (OPtype == "EDIT") {
                    sTitle = "修改下线产品计件物料清单";
                    sUrl = "AbnormalMtlEdit.aspx?";
                }
            }

            dialogOpen({
                id: "Form",
                title: sTitle,
                url: sUrl + "OPtype=" + OPtype + "&AbId=" + AbId,
                width: sWidth,
                height: sHeight,
                callBack: function (iframeId) {
                    top.frames[iframeId].AcceptClick($("#gridTable"));
                }
            });
        }

        function initAbPointContent() {
            $.ajax({
                url: "GetSetMfg.ashx",
                data: {
                    "Action": "MFG_WIP_DATA_ABNORMAL_POINT"
                },
                type: "post",
                async: false,
                datatype: "json",
                success: function (data) {
                    data = JSON.parse(data);
                    var strListContent  = '';
                    for (i in data) {
                        strListContent += '<option value ="' + data[i].ID + '">' + data[i].DisplayValue + '</option>';
                    }
                    $("#AbnormalPoint").append(strListContent);
                },
                error: function (msg) {
                    alert(msg.responseText);
                }
            });
        }

        Date.prototype.format = function(format){
            var o = {
                "M+" : this.getMonth()+1, //month
                "d+" : this.getDate(),    //day
                "h+" : this.getHours(),   //hour
                "m+" : this.getMinutes(), //minute
                "s+" : this.getSeconds(), //second
                "q+" : Math.floor((this.getMonth()+3)/3), //quarter
                "S" : this.getMilliseconds() //millisecond
            }
            if(/(y+)/.test(format)){ 
                format=format.replace(RegExp.$1,(this.getFullYear()+"").substr(4- RegExp.$1.length));
            }
            for(var k in o){
                if(new RegExp("("+ k +")").test(format)){
                    format = format.replace(RegExp.$1,RegExp.$1.length==1? o[k] :("00"+ o[k]).substr((""+o[k]).length));
                }
            }
            return format;
        }
        Date.prototype.DateAdd = function (strInterval, Number) {
            var dtTmp = this;
            switch (strInterval) {
                case 's': return new Date(Date.parse(dtTmp) + (1000 * Number));
                case 'n': return new Date(Date.parse(dtTmp) + (60000 * Number));
                case 'h': return new Date(Date.parse(dtTmp) + (3600000 * Number));
                case 'd': return new Date(Date.parse(dtTmp) + (86400000 * Number));
                case 'w': return new Date(Date.parse(dtTmp) + ((86400000 * 7) * Number));
                case 'q': return new Date(dtTmp.getFullYear(), (dtTmp.getMonth()) + Number * 3, dtTmp.getDate(), dtTmp.getHours(), dtTmp.getMinutes(), dtTmp.getSeconds());
                case 'm': return new Date(dtTmp.getFullYear(), (dtTmp.getMonth()) + Number, dtTmp.getDate(), dtTmp.getHours(), dtTmp.getMinutes(), dtTmp.getSeconds());
                case 'y': return new Date((dtTmp.getFullYear() + Number), dtTmp.getMonth(), dtTmp.getDate(), dtTmp.getHours(), dtTmp.getMinutes(), dtTmp.getSeconds());
            }
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
                                    <th><i class="fa fa-bar-chart fa-lg" style="padding-right: 5px;"></i><strong style="font-size:20px">产品下线管理</strong></th>
                                    <td></td>
                                </tr>
                            </table>
                        </div>
                        <div class="panel-body" style="text-align:left">
                            <table class="form" border="0" style="width:100%">
                                <tr>
                                    <td class="formTitle" style="width:180px;font-weight:bold;text-align:right">MES码:</td>                                    
                                    <td class="formValue">
                                        <input type="text" class="form-control" id="RFID" placeholder="MES码">
                                    </td>                                    
                                    <td class="formTitle" style="width:180px;font-weight:bold;text-align:right">订单编号:</td>                                    
                                    <td class="formValue">
                                        <input type="text" class="form-control" id="WorkOrderNumber" placeholder="订单编号">
                                    </td>  
                                </tr>
                                <tr>
                                    <td class="formTitle" style="width:180px;font-weight:bold;text-align:right">产品物料编码:</td>                                    
                                    <td class="formValue">
                                        <input type="text" class="form-control" id="GoodsCode" placeholder="产品物料编码">
                                    </td>                                    
                                    <td class="formTitle" style="width:180px;font-weight:bold;text-align:right">下线工序:</td>                                    
                                    <td class="formValue">
                                        <select class="form-control" id="AbnormalPoint">
                                            <option value = "">请选择...</option>
                                        </select>
                                    </td>  
                                </tr>
                                <tr>
                                    <td class="formTitle" style="width:180px;font-weight:bold;text-align:right">下线类型:</td>                                    
                                    <td class="formValue">
                                        <select class="form-control" id="AbnormalType">
                                            <option value ="">请选择...</option>
                                            <option value ="1">补修</option>
                                            <option value ="2">报废</option>
                                            <option value ="3">未完工</option>
                                        </select>
                                    </td> 
                                    <td></td>                                    
                                    <td></td>                                                                        
                                </tr>
                                <tr>                                  
                                    <td class="formTitle" style="width:180px;font-weight:bold;text-align:right">下线时间:</td>                                    
                                    <td colspan="2">
                                        <input type="text" id="FromTime" style="width:240px" onFocus="WdatePicker({dateFmt:'yyyy-MM-dd HH:mm', readOnly:true, highLineWeekDay:true, isShowClear:false})" class="Wdate timeselect" placeholder="下线起始时间">至
                                        <input type="text" id="ToTime"   style="width:240px" onFocus="WdatePicker({dateFmt:'yyyy-MM-dd HH:mm', readOnly:true, highLineWeekDay:true, isShowClear:false})" class="Wdate timeselect" placeholder="下线结束时间">
                                    </td>                                    
                                    <td class="formValue" style="text-align:right" colspan="1">                                           
                                        <a id="btn_Search" class="btn btn-primary"><i class="fa fa-search"></i>查询</a>
                                        <a id="btn_Create" class="btn btn-primary"><i class="fa fa-plus"></i>新建</a>
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
               width:60px;
           } 

           .formValue {
               font-size:15px;
               width:260px;
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
              width:60px;
          } 
          .formValue {
               font-size:20px;
               width:280px;
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
