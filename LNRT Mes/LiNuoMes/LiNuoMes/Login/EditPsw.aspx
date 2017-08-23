<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="EditPsw.aspx.cs" Inherits="LiNuoMes.Login.EditPsw" %>

<!DOCTYPE html>

<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
    <title></title>
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
    <%--<link href="../css/learun-ui.css" rel="stylesheet" />--%>
    <link href="../Content/adminLTE/css/index.css" rel="stylesheet" />
    <link href="../Content/scripts/plugins/jqgrid/jqgrid.css" rel="stylesheet" />
    <link rel="Shortcut icon" href="http://www.jq22.com/favicon.ico" />
    <link href="../Content/styles/learun-ui.css" rel="stylesheet" />
    <link href="../css/my.css" rel="stylesheet" media="screen">
    <script src="../Content/scripts/plugins/layout/jquery.layout.js"></script>
    <script src="../Content/scripts/plugins/dialog/dialog.js"></script>

    <script src="../Content/scripts/plugins/jqgrid/grid.locale-cn.js"></script>
    <script src="../Content/scripts/plugins/jqgrid/jqgrid.min.js"></script>
    <script src="../Content/scripts/utils/learun-ui.js"></script>
    <script src="../Content/scripts/utils/learun-form.js"></script>
    <link href="../css/zTreeStyle/metro.css" rel="stylesheet" />
    <script src="../js/jquery.ztree.all-3.5.min.js"></script>
    <script src="../My97DatePicker/WdatePicker.js"></script>
    <link href="../js/index.css" rel="stylesheet" />
    <script src="../js/register.js"></script>
    <style>
        html, body {
            height: 100%;
            width: 100%;
        }
    </style>
</head>
<body>
     <script>
         var UserID="";
         $(function () {
             UserID = '<%=Session["UserID"] %>';
             $("#adminNo").val(UserID);

         });
            

         //保存表单
         function AcceptClick() {

             var OldPsw = $("#oldpassword").val();
             var NewPsw = $("#password").val();
             //if (!verifyCheck._click()) return;
             if (!verifyCheck._click()) return false;

             $.ajax({
                 url: "EditPassword.ashx",
                 data: {
                     Action: "EditPsw" ,
                     UserID: UserID,
                     OldPsw: OldPsw,
                     NewPsw: NewPsw
                 },
                 async: true,
                 type: "post",
                 datatype: "json",
                 success: function (data) {
                     Loading(false);
                     data = JSON.parse(data);
                     if (data.result == "success") {
                         dialogMsg("保存成功", 1);
                         dialogClose();
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
    </script>
   
    <div class="reg-box" id="verifyCheck" style="margin-left: 10px; margin-top: 20px; margin-right: 30px;">
            <div class="part1">                	
                   <div class="item col-xs-12">
                       <span class="intelligent-label f-fl"><b class="ftx04">*</b>用户名：</span>    
                       <div class="f-fl item-ifo">
                           <input type="text" maxlength="20" class="txt03 f-r3 required"tabindex="1"  id="adminNo" data-valid="isNonEmpty" data-error="用户名不能为空" readonly/>                        
                           <span class="ie8 icon-close close hide"></span>
                           <label class="icon-sucessfill blank hide"></label>
                           <label class="focus"><span>当前账号</span></label>
                           <label class="focus valid"></label>
                       </div>
                   </div>
                      <div class="item col-xs-12">
                       <span class="intelligent-label f-fl"><b class="ftx04">*</b>旧密码：</span>    
                       <div class="f-fl item-ifo">
                           <input type="password" id="oldpassword" maxlength="20" class="txt03 f-r3required" tabindex="3" style="ime-mode:disabled;" onpaste="return  false"autocomplete="off" data-valid="isNonEmpty" data-error="密码不能为空" />
                           <span class="ie8 icon-close close hide" style="right:55px"></span>
                           <span class="showpwd" data-eye="password"></span>                        
                           <label class="icon-sucessfill blank hide"></label>
                           <label class="focus">请输入原密码</label>
                           <label class="focus valid"></label>
                           <span class="clearfix"></span>
                       </div>
                   </div>

                   <div class="item col-xs-12">
                       <span class="intelligent-label f-fl"><b class="ftx04">*</b>新密码：</span>    
                       <div class="f-fl item-ifo">
                           <input type="password" id="password" maxlength="20" class="txt03 f-r3required" tabindex="3" style="ime-mode:disabled;" onpaste="return  false"autocomplete="off" data-valid="isNonEmpty||between:6-20||level:2" dataerror="密码不能为空||密码长度6-20位||该密码太简单，有被盗风险，建议字母+数字的合" /> 
                           <span class="ie8 icon-close close hide" style="right:55px"></span>
                           <span class="showpwd" data-eye="password"></span>                        
                           <label class="icon-sucessfill blank hide"></label>
                           <label class="focus">6-20位英文（区分大小写）、数字、字符的组合</label>
                           <label class="focus valid"></label>
                           <span class="clearfix"></span>
                           <label class="strength">
                           	<span class="f-fl f-size12">安全程度：</span>
                           	<b><i>弱</i><i>中</i><i>强</i></b>
                           </label>    
                       </div>
                   </div>
                   <div class="item col-xs-12">
                       <span class="intelligent-label f-fl"><b class="ftx04">*</b>确认密码：</span>   
                       <div class="f-fl item-ifo">
                           <input type="password" maxlength="20" class="txt03 f-r3 required"tabindex="4" style="ime-mode:disabled;" onpaste="return  false"autocomplete="off" data-valid="isNonEmpty||between:6-16||isRepeat:password"data-error="密码不能为空||密码长度6-16位||两次密码输入不一致" id="rePassword" />
                           <span class="ie8 icon-close close hide" style="right:55px"></span>
                           <span class="showpwd" data-eye="rePassword"></span>
                           <label class="icon-sucessfill blank hide"></label>
                           <label class="focus">请再输入一遍上面的密码</label> 
                           <label class="focus valid"></label>                          
                       </div>
                   </div>
                  
           </div>
      </div>
</body>
</html>



