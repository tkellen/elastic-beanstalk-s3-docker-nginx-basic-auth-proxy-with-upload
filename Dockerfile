FROM nginx
RUN rm /etc/nginx/conf.d/default.conf
ADD nginx.conf /etc/nginx/conf.d
ADD .htpasswd /etc/nginx
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
