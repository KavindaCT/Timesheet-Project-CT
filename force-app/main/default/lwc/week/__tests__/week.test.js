import {createElement} from 'lwc'
import Week from 'c/week'
const mockEarningData = require("./data/earningData.json");
const mockWeekDays = require("./data/weekDaysData.json");

describe('c-week test suite', ()=>{   
    afterEach(() => {
        // The jsdom instance is shared across test cases in a single file so reset the DOM
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
    });

    test('currentWeekTest', ()=>{
        const element = createElement('c-week', {
            is:Week 
        })

        const earnVal = element.shadowRoot.querySelectorAll('c-earning');
        document.body.appendChild(element)

        earnVal.weekDays = mockWeekDays;
        element.earningData = mockEarningData;        
        element.currentWeek = {"weekNumber":0,"weekStart":"Mon Oct 03 2022","weekEnding":"Fri Oct 07 2022"};

        const name = element.currentWeek;
        const earningCheck = element.earningData

        return Promise.resolve().then(() => {
            expect(name.weekNumber).toBe(0);
            expect(earningCheck[0].weekNumber).toBe(1)
        })
    })

    test('add new Earning', ()=>{
        const element = createElement('c-week', {
            is:Week 
        })

        const earnVal = element.shadowRoot.querySelectorAll('c-earning');
        document.body.appendChild(element)

        element.earningData = mockEarningData;  
        earnVal.weekDays = mockWeekDays;
        element.currentWeek = {"weekNumber":0,"weekStart":"Mon Oct 03 2022","weekEnding":"Fri Oct 07 2022"};
        const newEarning = {
            id: 10,
            earningType: "Half Day Leave",
            hours: [],
            weekNumber: '1',
            deleteFlag: false
          };

        const handler = jest.fn();
        element.addEventListener('click', handler);
    
        return Promise.resolve().then(() => {
            const timeSM = element.shadowRoot.querySelectorAll('lightning-button');
            console.log(timeSM.length);
            //timeSM.click();
            timeSM[0].addEventListener('click', handler)
            timeSM[0].dispatchEvent(new CustomEvent('click', {detail: newEarning}));
            
            //expect(handler).toHaveBeenCalled();
            expect(handler).toHaveBeenCalledTimes(1);
        })
    })

    test('handlechange earning type', ()=>{
        const element = createElement('c-week', {
            is:Week 
        })
        const earnVal = element.shadowRoot.querySelectorAll('c-earning');
        document.body.appendChild(element)

        earnVal.weekDays = mockWeekDays;
        element.earningData = mockEarningData;        
        element.currentWeek = {"weekNumber":0,"weekStart":"Mon Oct 03 2022","weekEnding":"Fri Oct 07 2022"};

        const handler = jest.fn();    

        
        const childElement = element.shadowRoot.querySelectorAll('c-earning');
        console.log(childElement.length);
        element.addEventListener('changeearning', handler);

        return Promise.resolve().then(() => {
            const timeSM = element.shadowRoot.querySelectorAll('c-earning');
            console.log(timeSM.length);
            timeSM[0].addEventListener('changeearning', handler)
            timeSM[0].dispatchEvent(new CustomEvent('changeearning', {detail: {"earningType":"Half Day Leave","id":"10"}}));
            expect(handler).toHaveBeenCalledTimes(1);
        })
    })

    test('removeEarning', ()=>{
        const element = createElement('c-week', {
            is:Week 
        })
        const earnVal = element.shadowRoot.querySelectorAll('c-earning');
        document.body.appendChild(element)

        earnVal.weekDays = mockWeekDays;
        element.earningData = mockEarningData;        
        element.currentWeek = {"weekNumber":0,"weekStart":"Mon Oct 03 2022","weekEnding":"Fri Oct 07 2022"};

        const handler = jest.fn();    
        element.addEventListener('remove', handler)

        return Promise.resolve().then(() => {
            const timeSM = element.shadowRoot.querySelectorAll('c-earning');
            console.log(timeSM.length);
            timeSM[0].addEventListener('remove', handler)
            timeSM[0].dispatchEvent(new CustomEvent('remove', {detail: {"earningType":"Half Day Leave","id":"10"}}));
            expect(handler).toHaveBeenCalledTimes(1);
        })
    })

    test('change value', ()=>{
        const element = createElement('c-week', {
            is:Week 
        })
        const earnVal = element.shadowRoot.querySelectorAll('c-earning');
        document.body.appendChild(element)

        earnVal.weekDays = mockWeekDays;
        element.earningData = mockEarningData;        
        element.currentWeek = {"weekNumber":0,"weekStart":"Mon Oct 03 2022","weekEnding":"Fri Oct 07 2022"};
        const handler = jest.fn();    

        return Promise.resolve().then(() => {
            const timeSM = element.shadowRoot.querySelectorAll('c-earning');
            timeSM[0].addEventListener('changevalue', handler)
            timeSM[0].dispatchEvent(new CustomEvent('changevalue', {detail: {"earningType":"Half Day Leave","id":"10"}}));
            expect(handler).toHaveBeenCalledTimes(1);
        })
    })
    
})