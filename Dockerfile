FROM nginx
RUN rm /etc/nginx/conf.d/default.conf
COPY nginx.conf /etc/nginx/conf.d
COPY .htpasswd /etc/nginx/conf.d
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
