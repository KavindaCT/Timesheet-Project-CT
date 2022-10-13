import { createElement } from 'lwc';
import PreviousTimesheet from 'c/previousTimesheet';

describe('c-previous-timesheet', () => {
    afterEach(() => {
        // The jsdom instance is shared across test cases in a single file so reset the DOM
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
    });

    it('Previous', () => {
        const element = createElement('c-previous-timesheet', {
            is: PreviousTimesheet
        });

        element.timesheet = '809';

        document.body.appendChild(element);

        const handler = jest.fn();
        element.addEventListener('view', handler);

        const div = element.shadowRoot.querySelector('lightning-button');
        div.dispatchEvent(new CustomEvent('click'));
        return Promise.resolve().then(() => {
            expect(handler).toHaveBeenCalled();
        });
    });
});

