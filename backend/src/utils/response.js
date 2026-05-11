/**
 * Standard success response helper.
 * @param {*} data - Response payload
 * @param {string} message - Success message
 * @returns {{ success: boolean, data: *, message: string }}
 */
const success = (data, message = 'Success') => {
  return {
    success: true,
    data,
    message,
  };
};

/**
 * Standard error response helper.
 * @param {string} message - Error message
 * @param {number} code - HTTP status code
 * @returns {{ success: boolean, error: { message: string, code: number } }}
 */
const error = (message = 'Internal Server Error', code = 500) => {
  return {
    success: false,
    error: {
      message,
      code,
    },
  };
};

module.exports = { success, error };
