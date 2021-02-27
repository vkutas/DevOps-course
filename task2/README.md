File ***mean_origin.sh*** contains original script from task 2.  
File ***mean_v2.sh*** contains script which produce the same result as ***mean_origin.sh*** but without **grep** and pattern matching.  
File ***best_march.sh*** contains implementation of part 3 of task 2:  
>tell me which March the price was the least volatile since 2015? To do so have to find the difference between MIN and MAX values for the period.   
The output of the script is the year of March when the EUR/RUB rate was less volatile.  

To do so, we get all subarrays of *prices* array and add two new values into it - **month** and **year**. In order to get these values, first we need to convert Unix time from milliseconds to seconds and then pass the resulting value in to ***strftime()*** function with the desired pattern.  
    .prices[] | [. | .[0], ((.[0] / 1000) | strftime("%m")), ((.[0] / 1000) | strftime("%y")), .[1]] 
This *jq* filter returns an array which has 4 elements: 
0.  **Timestamp**  - from original array  
1.  **Number of Month** - derived from timestamp  
2.  **year** - derived from timestamp  
3.  **EUR/RUB rate** - from original array

In the next *jq* filter we find all subarrays which contains entries related to the March of each year.  
    select(.[1] == "03")

In the next for loop we find MIN and MAX value for each year and calculate the difference between them. Then we print the year which has the least value.