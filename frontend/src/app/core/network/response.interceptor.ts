import { HttpErrorResponse, HttpInterceptorFn, HttpResponse } from '@angular/common/http';
import { inject } from '@angular/core';
import { catchError, tap } from 'rxjs/operators';
import { throwError } from 'rxjs';
import { ToastService } from '../services/toast.service';

export const responseInterceptor: HttpInterceptorFn = (req, next) => {
  const toastService = inject(ToastService);

  return next(req).pipe(
    tap((event) => {
      // For showing success messages if the backend returns { message: "..." }
      if (event instanceof HttpResponse) {
        if (event.body && typeof event.body === 'object' && 'message' in event.body) {
          // Some GET requests might return a message, we might not want to toast on every GET
          // But as requested, "see response of all requests", we'll log it if it explicitly has a message.
          if (req.method !== 'GET') {
             toastService.success((event.body as any).message);
          }
        }
      }
    }),
    catchError((error: HttpErrorResponse) => {
      let errorMessage = 'حدث خطأ غير معروف';
      
      if (error.error instanceof ErrorEvent) {
        // Client-side error
        errorMessage = `خطأ: ${error.error.message}`;
      } else {
        // Server-side error
        if (error.error && typeof error.error === 'object') {
          if (error.error.message) {
            errorMessage = error.error.message;
          } else if (error.error.error) {
            errorMessage = error.error.error;
          } else if (error.error.title) {
            errorMessage = error.error.title;
          } else if (error.error.detail) {
            errorMessage = error.error.detail;
          } else {
            // Handle plain string if possible, or fallback
            errorMessage = `رمز الخطأ: ${error.status}\nالرسالة: ${error.message}`;
          }
        } else if (typeof error.error === 'string') {
          errorMessage = error.error;
        } else {
          errorMessage = `رمز الخطأ: ${error.status}\nالرسالة: ${error.message}`;
        }
      }

      toastService.error(errorMessage);
      return throwError(() => error);
    })
  );
};
