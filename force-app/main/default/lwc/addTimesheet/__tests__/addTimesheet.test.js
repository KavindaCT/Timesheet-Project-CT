import {createElement} from 'lwc'
import AddTimesheet from 'c/addTimesheet'
import getRecentTimesheet from "@salesforce/apex/TimesheetDataService.getRecentTimesheet";


const mockGetContactList = require('./data/testData.json');


jest.mock(
    '@salesforce/apex/TimesheetDataService.getRecentTimesheet',
    ()=> {
        const {
            createApexTestWireAdapter
        } = require('@salesforce/sfdx-lwc-jest');
        return {
            default: createApexTestWireAdapter(jest.fn(() => Promise.resolve()))
        };
    },
    { virtual: true }
);
describe('c-add-timesheet test suite', ()=>{
    test('ChangeView', ()=>{
        const element = createElement('c-add-timesheet', {
            is:AddTimesheet 
        })
        document.body.appendChild(element)
        
        
        const handler = jest.fn();
        element.addEventListener('lightning__showtoast', handler);

        const timeSM = element.shadowRoot.querySelector('lightning-button');
        timeSM.dispatchEvent(new CustomEvent('click'));
        return Promise.resolve().then(() => {
            expect(handler).toHaveBeenCalled();
        });
    })
 
    test('API Test suite', ()=>{
        const element = createElement('c-add-timesheet', {
            is:AddTimesheet 
        })
        document.body.appendChild(element);
        
        element.currentUserFullName = {value:'test'}
        const name = element.currentUserFullName;

        element.currentUserId = {value:'test'}
        const userId = element.currentUserId;

        const timeSM = element.shadowRoot.querySelector('lightning-combobox');
        timeSM.dispatchEvent(new CustomEvent('change', { detail: { value: "timesheet" } }));

        return Promise.resolve().then(() => {
            expect(name.value).toBe("test");
            expect(userId.value).toBe("test");
        });
    })

    test('Create Timesheet Test1', async()=>{
        const element = createElement('c-add-timesheet', {
            is:AddTimesheet 
        })
        element.result = {value:'test'};
        document.body.appendChild(element);
        getRecentTimesheet.mockResolvedValue(mockGetContactList[0]);

        element.currentUserFullName = {value:'test'}
        const name = element.currentUserFullName;

        element.currentUserId = {value:'test'}
        const userId = element.currentUserId;

        const timeSM = element.shadowRoot.querySelector('lightning-combobox');
        timeSM.result = 2;
  
        timeSM.dispatchEvent(new CustomEvent('change', { detail: { Id:mockGetContactList[0].Id,Name:mockGetContactList[0].Name }}));

        return Promise.resolve().then(() => {
            expect(userId.value).toBe('test');
        });
    })
    
})