# Opsview: App bugs

Copy this block and start filling.

- **[Bug name]**
    
    **Screen**: 
    
    **Screenshot**:
    
    **Issue**:
    
    **Ideal behaviour**:
    

Bugs, Reported by Braj:

- Too many failed attempts on selfie capture bug, and camera doesn’t open.
    
    **Screen**:  Selfie capture
    
    **Screenshot**:
    
    ![image.png](Opsview%20App%20bugs/image.png)
    
    **Issue**: Trying to open the camera during selfie upload, keeps loading and routes to this screen after I clicked on the button 2-3 times.
    
    **Ideal behaviour**: 
    
    - It should never lock out the user
    - it should open the camera in one go very smoothly.
- Exam name and username should auto lowercase
    
    **Screen**: login screen
    
    **Screenshot**: 
    
    ![image.jpg](Opsview%20App%20bugs/image.jpg)
    
    **Issue**: exam code and username are not automatically turning into lowercase
    
    **Ideal behaviour**: make letters to lowercase automatically while typing but password should be case sensitive 
    
- Post login, jumping directly to shift selection
    
    **Screen**: select shift
    
    **Screenshot**:
    
    **Issue**:
    
    **Ideal behaviour**: Profile creation and Training link screen is completely skipped
    
- No signal sent to backend post task downloaded
    
    **Screen**: Post confirmation screen
    
    **Screenshot**:
    
    **Issue**: Not sending will show that user has not never downloaded tasks to work
    
    **Ideal behaviour**: An even if type TASK_DOWNLOADED IS NOT SENT
    
- Shift Tab is not adjusting to active shift or non empty ( 1 shift only)
    
    **Screen**:  Shift Selection
    
    ![image.jpg](Opsview%20App%20bugs/image%201.jpg)
    
    **Screenshot**:
    
    **Issue**: Should not show empty tab instead auto navigate to tab that has some shifts
    
    **Ideal behaviour**:ideally shift tab should be shifted where active shift is lying but if only 1 shift, move to where non empty type tab
    
- Dont show seconds part in shift timings
    
    **Screen**:  select shift
    
    **Screenshot**: 
    
    ![image.jpg](Opsview%20App%20bugs/image%202.jpg)
    
    **Issue**: seconds make no sense and is not kept at backend as well
    
    **Ideal behaviour**: show human readable Hour and minute only
    
- Age, Mobile and Aadhar basic validations are missing
    
    **Screen**:  Operator Profile
    
    **Screenshot**: 
    
    ![image.jpg](Opsview%20App%20bugs/image%203.jpg)
    
    **Issue**: Basic validations are missing and continue selfie option is active
    
    **Ideal behaviour**: Continue selfie should be active only when basic validations are checked. mobile otp can be kept without validations when network is not there
    
- Profile Submit is failing
    
    **Screen**: Verify Location and Selfie
    
    **Screenshot**: 
    
    ![image.jpg](Opsview%20App%20bugs/image%204.jpg)
    
    **Issue**:Profile creation is failing
    
    **Ideal behaviour**:
    
- Retake Selfie is not working
    
    **Screen**:  Verify Location & Selfie
    
    **Screenshot**: 
    
    ![image.jpg](Opsview%20App%20bugs/image%205.jpg)
    
    **Issue**: retake not working
    
    **Ideal behaviour**:
    
- While submitting operator profile, many error popups coming,
    
    **Screen**:  Sumit Operator Profile
    
    **Screenshot**: 
    
    **Issue**: Random popups saying something not working
    
    **Ideal behaviour**: l
    
- Training Duration and Priority shown while nothing is coming from api
    
    **Screen**:  Training Required
    
    **Screenshot**: 
    
    ![image.jpg](Opsview%20App%20bugs/image%206.jpg)
    
    **Issue**:
    
    **Ideal behaviour**: should show a simple training link ( default image or icon can be used) on center of the screen
    
- Training skip option is not there
    
    **Screen**: 
    
    **Screenshot**:
    
    **Issue**:
    
    **Ideal behaviour**:
    
- Inside/outside info not shown on while clicking photos
    
    **Screen**:  Task Detail
    
    **Screenshot**: 
    
    ![image.jpg](Opsview%20App%20bugs/image%207.jpg)
    
    ![image.jpg](Opsview%20App%20bugs/image%208.jpg)
    
    **Issue**: inside or outside should he showint while use is taking photo. Also no galley is allowed in the whole app
    
    **Ideal behaviour**: check wireframes
    
- No-img-cnt is ignored which controls when user can submit
    
    **Screen**:  Task Detail
    
    **Screenshot**:
    
    ![image.jpg](Opsview%20App%20bugs/image%209.jpg)
    
    **Issue**: User is able to click more photos than mentioned
    
    **Ideal behaviour**: Complete task should be replaced with Submit Task, it should be active only when  required number of images are taken ( not less nor more)
    
- Cant check last submission complete image
    
    **Screen**:  Task Detail
    
    **Screenshot**: 
    
    ![image.jpg](Opsview%20App%20bugs/image%2010.jpg)
    
    **Issue**: not able to check full image
    
    **Ideal behaviour**: user can see last submission full detail
    
- Even if Internet is available, still showing un synced
    
    **Screen**:  Sumitted Tab in a shift
    
    **Screenshot**: 
    
    ![image.jpg](Opsview%20App%20bugs/image%2011.jpg)
    
    **Issue**: data is not synced automatically even when internet is available 
    
    **Ideal behaviour**: If internet is available, sync data immediately 
    
- Sync required in Profile section even if synced
    
    **Screen**:  Profile
    
    **Screenshot**: 
    
    ![image.jpg](Opsview%20App%20bugs/image%2012.jpg)
    
    **Issue**: showing sync required message
    
    **Ideal behaviour**: if synced, it should green
    
- Random message is populated in Observations of a task
    
    **Screen**:  Task Detail
    
    **Screenshot**: 
    
    ![image.jpg](Opsview%20App%20bugs/image%2013.jpg)
    
    **Issue**: the above message I typed for another task but its showing in this task as well
    
    **Ideal behaviour**: ideally task details and their submissions are isolated
    
- All tasks showing un synced
    
    **Screen**: Submitted 
    
    **Screenshot**: 
    
    ![image.jpg](Opsview%20App%20bugs/image%2014.jpg)
    
    **Issue**: on submitting another task, synced tasks too are showing un synced 
    
    **Ideal behaviour**: only unsynced tasks should be shown as synced
    
- Only 1st Task is showing synced even if on manual sync, it showed all synced
    
    **Screen**:  submitted 
    
    **Screenshot**: 
    
    ![image.jpg](Opsview%20App%20bugs/image%2015.jpg)
    
    **Issue**: showing only 1 item synced
    
    **Ideal behaviour**: all should be synced and actual status should be shown
    
- Only 1 task is showing image and message but that of different tasks
    
    **Screen**:  task detail
    
    **Screenshot**: 
    
    ![image.jpg](Opsview%20App%20bugs/image%2016.jpg)
    
    **Issue**: The submissions were task wise but data is shown from some other tasks and old data of this task is totally lost. Also data of other task is lost
    
    **Ideal behaviour**: each task has its own data submissions
    
- Logout not working
    
    **Screen**:  Profile
    
    **Screenshot**: 
    
    ![image.jpg](Opsview%20App%20bugs/image%2017.jpg)
    
    **Issue**: logout is not working
    
    **Ideal behaviour**: