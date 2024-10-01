class AppUrl{
  static const port = '3004';

  // static const hostedip = '52.66.145.37';

  static const hostedip = 'testapi.rxroute.in';

  // static const localip = '192.168.1.10';


  // static var baseUrl = 'http://${hostedip}:${port}';
  static var baseUrl = 'https://${hostedip}';

  // static var hostedUrl = 'https://testapi.rxroute.in';

  static var login = '$baseUrl/rep/login';

  static var getLeaveRequest = '${baseUrl}/manager/getLeaveRequest';

  static var getdoctors = '${baseUrl}/rep/getDr';

  static var add_doctor_rep = '${baseUrl}/rep/add_dr';

  static var delete_doctor = '${baseUrl}/rep/delete_doctor';

  static var manager_registration = '$baseUrl/manager/managerRegister';

  static var get_employee = '$baseUrl/manager/get_Replist';

  static var accept_leave = '$baseUrl/manager/acceptLeave';

  static var get_leaves = '$baseUrl/rep/leaveHistory';

  static var apply_leave = '${baseUrl}/manager/leaveRequest';

  static var add_employee = '${baseUrl}/user/userRegistration';

  static var single_doctor_details = '$baseUrl/rep/doctorDetail';

  static var single_employee_details = '$baseUrl/rep/singleDetails';

  static var get_expense_request_rep = '$baseUrl/rep/repExpense_list';

  static var get_expense_requests_manager = '$baseUrl/manager/list_expenseRequest';

  static var searchdoctors = '$baseUrl/rep/filter_dr';

  static var totaldoctorscount = '$baseUrl/rep/totalDr';

  static var totalrepcount = '$baseUrl/rep/totalRep';

  static var expense_request = '$baseUrl/rep/report_expense';

  static var add_chemist = '$baseUrl/rep/add_chemist';

  static var get_chemists = '$baseUrl/rep/get_chemist';

  static var getaddedChemist = '$baseUrl/user/addedChemist';

  static var search_chemists = '$baseUrl/rep/search_chemist';

  static var delete_chemists = '$baseUrl/rep/delete_chemist';

  static var list_headqrts = '$baseUrl/rep/get_headquarters';

  static var list_products = '$baseUrl/rep/get_product';

  static var generate_tp = '$baseUrl/rep/travel_plan';

  static var list_tp = '$baseUrl/rep/get_travelPlan';

  static var managers_list = '$baseUrl/manager/list_manager';

  static var delete_employee = '$baseUrl/rep/delete_rep';

  static var getEvents = '$baseUrl/rep/notifications';

  static var accept_reject_exp_mngr = '$baseUrl/manager/change_reportStatus';

  static var mark_as_visited = '$baseUrl/rep/markAsVisited';
  static var mark_as_visitedWithTP = '$baseUrl/rep/markAsVisitedForTp';

  static var edit_doctor = '$baseUrl/manager/editDoctor';

  static var search_expense = '$baseUrl/rep/search_expenseTable';

  static var search_leave = '$baseUrl/rep/searchByDate';

  static var singleChemistDetails = '$baseUrl/rep/singleChemistDetail';

  static var edit_chemist = '$baseUrl/rep/edit_chemist';

  static var edit_employee = '$baseUrl/manager/editRep';

  static var search_employee = '$baseUrl/rep/search_Rep';

  static var specialisation =  '$baseUrl/rep/getSpecialization';

  static var getvisitedDates = '$baseUrl/rep/getVisitedDates';

  static var gettingapproval_doctors = '$baseUrl/user/doctorForApproval';

  static var approving_doctors = '$baseUrl/user/approveDoctors';

  static var doctorsInTp = '$baseUrl/user/doctorsInTp';

  //travelplan

  static var submitAutoTP = '$baseUrl/user/SubmitAutomaticTp';
// get all created tp
  static var getTravelPlans = '$baseUrl/user/userAddedTP';
  //get created tp
  static var getCreatedTP  = '$baseUrl/rep/getTravelPlan';

  static var generateautoTP = '$baseUrl/generate-visit-plan';

  static var generateManulTP = '$baseUrl/rep/createTravelplan';

  static var cancelTp = '$baseUrl/rep/cancelTP';

  static var confirmTP = '$baseUrl/rep/changeStatus';

  //approving manager the tp
  static var approveUsersTP = '$baseUrl/user/userAddedTP';

  //list managers rep tp
  static var getUserAddedTP = '$baseUrl/user/getUserAddedTp';

  static var approveUserAddedTP = '$baseUrl/user/approveTp';

  static var rejectUserAddedTP = '$baseUrl/user/rejectTp';

  static var checkTPinMonth = '$baseUrl/user/findTpAddedMonth';

  //userperformance
  // get doctor visit data
  static var getuserPerformance = '$baseUrl/user/Performance';

  static var getAddedDoctors = '$baseUrl/user/getAddedDoctor';

  //reports
 static var getallVisitData = '$baseUrl/user/visitedCount';

 static var userPerformance = '$baseUrl/user/userPerformance';

 //listdoctorsforcalendar

  static var listDoctors = '$baseUrl/user/listDoctors';

}
